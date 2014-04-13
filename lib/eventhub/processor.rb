module EventHub
	class Processor

		attr_accessor :name, :folder

		include Helper

		def initialize(name=nil)
			@name = name || class_to_array(self.class)[1..-1].join(".")
			@folder = Dir.pwd

			@started = Time.now

			@messages_successful 		= 0
			@messages_unsuccessful 	= 0

			@restart = true
		end

		def configuration
			EventHub::Configuration.instance.data
		end

		def server_host
			configuration.get('server.host') || 'localhost'
		end

		def server_user
			configuration.get('server.user') || 'admin'
		end

		def server_password
			configuration.get('server.password') || 'admin'
		end

		def server_management_port
			configuration.get('server.management_port') || 15672
		end

		def server_vhost
			configuration.get('server.vhost') || 'event_hub'
		end

		def connection_settings
			{ user: server_user, password: server_password, host: server_host, vhost: server_vhost }
		end

		def listener_queue
			configuration.get('processor.listener_queue') || 'undefined_listener_queue'
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

			EventHub.logger.info("Processor [#{@name}] base folder [#{@folder}]")

			channel = nil

			while @restart

				begin 
					AMQP.start(self.connection_settings) do |connection, open_ok|

						@connection = connection
						
						# deal with tcp connection issues
						@connection.on_tcp_connection_loss do |conn, settings|
				  		EventHub.logger.warn("Processor lost tcp connection. Trying to restart in #{self.restart_in_s} seconds...")
				  		stop_processor(true)
				  	end

						# create channel
						channel = AMQP::Channel.new(@connection)
				  
				  	# connect to queue
				  	@queue = channel.queue(self.listener_queue, durable: true, auto_delete: false)

				  	# subscribe to queue
					  @queue.subscribe(:ack => true) do |metadata, payload|	  	

					  	
					  	begin
					  		messages_to_send = []

					  		# try to convert to Evenhub message
					  		message = Message.from_json(payload)
					  		EventHub.logger.info("-> #{message.to_s}")

					  		if message.status_code == STATUS_INVALID
					  			messages_to_send << message
					  			EventHub.logger.info("-> #{message.to_s} => Put to queue [#{EH_X_INBOUND}].")
					  		else
						  		# pass received message to handler or dervied handler
						  		messages_to_send = Array(handle_message(message))
						  	end

					  		# forward invalid or returned messages to dispatcher
						  	messages_to_send.each do |message|
						  		send_message(message)
						  	end
						  	channel.acknowledge(metadata.delivery_tag)
						  	@messages_successful += 1
						  	
					  	rescue => e
					  		channel.reject(metadata.delivery_tag,false)
					  		@messages_unsuccessful += 1
					  		EventHub.logger.error("Unexpected exception in handle_message method: #{e}. Message dead lettered.")
								EventHub.logger.save_detailed_error(e)
					  	end
					  end

					  EventHub.logger.info("Processor [#{@name}] is listening to vhost [#{self.server_vhost}], queue [#{self.listener_queue}]")

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
					EventHub.logger.error("Unexpected exception: #{e}, see => #{id}. Trying to restart in #{self.restart_in_s} seconds...")
					
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
				response = RestClient.get "http://#{self.server_user}:#{self.server_password}@#{self.server_host}:#{self.server_management_port}/api/queues/#{self.server_vhost}/#{self.listener_queue}/bindings", { :content_type => :json}
  			data = JSON.parse(response.body)
  	
  			if response.code != 200
  				EventHub.logger.warn("Watchdog: Server did not answered properly. Trying to restart in #{self.restart_in_s} seconds...")
  				EventMachine.add_timer(self.restart_in_s) { stop_processor(true) }
  			elsif data.size == 0
  				EventHub.logger.warn("Watchdog: Something is wrong with the vhost, queue, and/or bindings. Trying to restart in #{self.restart_in_s} seconds...")
  				EventMachine.add_timer(self.restart_in_s) { stop_processor(true) }
  				# does it make sence ? Needs maybe more checks in future
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
			message.origin_site_id 		= 'global'

			message.process_name    	= 'event_hub.heartbeat'

			now = Time.now
			message.body = {
				 heartbeat: {
				 started: 							now_stamp(@started),
				 stamp_last_beat:       now_stamp(now), 
				 uptime:                duration(now-@started),
				 heartbeat_cycle_in_s: 	self.heartbeat_cycle_in_s,
				 served_queues: 				[self.listener_queue],
				 host: 									get_host,
				 ip_adresses:           get_ip_adresses,
				 messages: {
				 	total: 								@messages_successful+@messages_unsuccessful,
				 	successful: 					@messages_successful,
				 	unsuccessful: 				@messages_unsuccessful
				 	}
				}
			}

			# send heartbeat message
			send_message(message)

			EventMachine.add_timer(self.heartbeat_cycle_in_s) { heartbeat }
		end

		# send message
		def send_message(message,exchange_name=EH_X_INBOUND)
			AMQP::Channel.new(@connection) do |channel|
				channel.direct(exchange_name, :durable => true, :auto_delete => false) do |exchange, declare_ok|
      		exchange.publish(message.to_json, :persistent => true)
      	end
			end
		rescue => e
				EventHub.logger.error("Unexpected exception while sending message to [#{exchange_name}]: #{e}")
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

			# stop connection and event loop
			if @connection
				@connection.disconnect if @connection.connected?
				EventMachine.stop if EventMachine.reactor_running?
			end
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