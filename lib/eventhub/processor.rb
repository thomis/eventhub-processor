module EventHub
	class Processor

		attr_accessor :name, :folder

		include Helper

		def initialize(name=nil)
			@name = name || class_to_string(self.class)
			@folder = Dir.pwd

			@started = Time.now

			@messages_successful 		= 0
			@messages_unsuccessful 	= 0

			@restart = true
		end

		def configuration
			EventHub::Configuration.instance.data
		end

		def host
			configuration.get('server.host') || 'localhost'
		end

		def user
			configuration.get('server.user') || 'admin'
		end

		def password
			configuration.get('server.password') || 'admin'
		end

		def management_port
			configuration.get('server.management_port') || 15672
		end

		def listener_queue
			configuration.get('processor.listener_queue') || 'inbound'
		end

		def vhost
			configuration.get('server.vhost') || nil
		end

		def watchdog_cycle_in_s
			configuration.get('processor.watchdog_cycle_is_s') || 15
		end

		def restart_in_s
			configuration.get('processor.restart_in_s') || 15
		end

		def heartbeat_cycle_in_s
			configuration.get('processor.heartbeat_cycle_in_s') || 300
		end

		def start(detached=false)
			daemonize if detached

			while @restart

				begin 
					AMQP.start(configuration.get('server')) do |connection, open_ok|

						@connection = connection
						
						# deal with tcp connection issues
						@connection.on_tcp_connection_loss do |conn, settings|
				  		EventHub.logger.warn("Processor lost tcp connection. Trying to restart in #{@restart_in_s} seconds...")
				  		stop_processor(true)
				  	end

						# create channel
						@channel = AMQP::Channel.new(@connection)
				  	@channel.auto_recovery = true
				  
				  	# connect to queue
				  	@queue = @channel.queue(self.listener_queue, durable: true, auto_delete: false)

				  	# subscribe to queue
					  @queue.subscribe(:ack => true) do |metadata, payload|
					  	begin
						  	if handle_message(metadata,payload)
						  		raise
						  		metadata.ack
						  	else
						  		metadata.nack
						  	end
					  	rescue => e
					  		EventHub.logger.error("Unexpected exception in handle_message method: #{e}")
								EventHub.logger.save_detailed_error(e)
					  	end
					  end

					  EventHub.logger.info("Processor [#{@name}] is listening to queue [#{self.listener_queue}], base folder [#{@folder}]")

					  # Singnal Listening
					  Signal.trap("TERM") {stop_processor}
					  Signal.trap("INT")  {stop_processor}

					  # Various timers
					  EventMachine.add_timer(@watchdog_cycle_in_s) { watchdog }

					  heartbeat
					end
				rescue => e
					Signal.trap("TERM") { stop_processor }
					Signal.trap("INT")  { stop_processor }

					id = EventHub.logger.save_detailed_error(e)
					EventHub.logger.error("Unexpected exception: #{e}, see => #{id}")
					
					sleep_break self.restart_in_s
				end

			end # while

			EventHub.logger.info("Processor [#{@name}] has been stopped")
		ensure
			# remove pid file
			begin
				File.delete("#{@folder}/#{@name}.pid")	
			rescue
				# ignore exceptions here
			end
		end

		def handle_message(metadata,payload)
			raise "Please implement method in derived class"
		end

		def watchdog
			begin
				response = RestClient.get "http://#{self.user}:#{self.password}@#{self.host}:#{self.management_port}/api/queues/#{self.vhost}/#{self.listener_queue}/bindings", { :content_type => :json}
  			data = JSON.parse(response.body)
  	
  			if response.code != 200
  				EventHub.logger.warn("Watchdog: Server did not answered properly. Trying to restart in #{self.restart_in_s} seconds...")
  				stop_processor
  			elsif data.size == 0
  				EventHub.logger.warn("Watchdog: Something is wrong with the vhost, queue, and/or bindings. Trying to restart in #{self.restart_in_s} seconds...")
  				stop_processor
  			else
  				# Watchdog is happy :-)
					# add timer for next check
					EventMachine.add_timer(self.watchdog_cycle_in_s) { watchdog }
				end	
					
			rescue => e
				EventHub.logger.error("Watchdog: Unexpected exception: #{e}. Trying to restart in #{self.restart_in_s} seconds...")
				stop_processor
			end
		end

		def heartbeat
			message = Message.new
			message.origin_module_id 	= @name
			message.origin_type 			= "processor"
			message.origin_site_id 		= 'chbs'

			message.process_name    	= 'event_hub.heartbeat'

			message.body = {
				 heartbeat: {
				 started: 							@started,
				 stamp_last_beat:       Time.now, 
				 heartbeat_cycle_in_s: 	self.heartbeat_cycle_in_s,
				 served_queues: 				[self.listener_queue],
				 messages: {
				 	total: 								@messages_successful+@messages_unsuccessful,
				 	successful: 					@messages_successful,
				 	unsuccessful: 				@messages_unsuccessful
				 	}
				}
			}

			send_to_dispatcher(message.to_json)

			EventMachine.add_timer(self.heartbeat_cycle_in_s) { heartbeat }
		end

		def send_to_dispatcher(payload)
			confirmed = true

			connection = Bunny.new({hostname: self.host, user: self.user, password: self.password, vhost: "event_hub"})
			connection.start

			channel = connection.create_channel
      channel.confirm_select

    	channel.default_exchange.publish(payload,routing_key: EVENT_HUB_QUEUE_INBOUND, persistent: true)
    	success = channel.wait_for_confirms

    	if !success
      	EventHub.logger.error("Message has not been confirmed by the server to be received !!!")
    		confirmed = false
    		@messages_unsuccessful += 1
    	else
    		@messages_successful += 1	
    	end

      channel.close   
      connection.close

      confirmed
		end

  	def sleep_break( seconds ) # breaks after n seconds or after interrupt
  		while (seconds > 0)
    		sleep(1)
    		seconds -= 1
    		break unless @restart
  		end
		end

		private

		def stop_processor(restart=false)
			@restart = restart

			# stop event loop
			@connection.disconnect { 
				EventHub.logger.info("Processor [#{@name}] is stopping main event loop")
				EventMachine.stop
			}
		end

		def daemonize
			EventHub.logger.info("Processor [#{@name}] is going to start as daemon")
		
			# daemonize
			Process.daemon

		  # write daemon pid
  		IO.write("#{@folder}/#{@name}.pid",Process.pid.to_s)
		end

	end
end