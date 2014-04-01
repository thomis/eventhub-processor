module EventHub
	class Processor

		def hostname
			configuration.get('server.hostname') || 'localhost'
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

		def queue_name
			configuration.get('processor.queue') || 'inbound'
		end

		def vhost
			configuration.get('server.vhost') || nil
		end

		def watchdog_cycle
			configuration.get('processor.watchdog_cycle') || 5
		end

		def configuration
			EventHub::Configuration.instance.data
		end



		def start
			restart = true
			while restart

				begin 
					AMQP.start(configuration.get('server')) do |connection, open_ok|
						
						# deal with tcp connection issues
						connection.on_tcp_connection_loss do |conn, settings|
				  		EventHub.logger.warn("Processor lost tcp connection. Trying to restart in 5 seconds...")
				  		sleep 5
				    	EventMachine.stop
				  	end

						# create channel
						channel = AMQP::Channel.new(connection)
				  	channel.auto_recovery = true
				  
				  	# connect to queue
				  	queue = channel.queue(configuration.get('processor.queue'), durable: true, auto_delete: false)

				  	# subscribe to queue
					  queue.subscribe do |metadata, payload|
					  	handle_heartbeat(payload)
					  	handle_message(metadata,payload)
					  end

						# Features to stop main event loop
						stop_main_loop = Proc.new {
					    connection.disconnect { 
					    	EventHub.logger.info("Processor is stopping main event loop")
					    	EventMachine.stop
					    	restart = false
					    }
				  	}

					  Signal.trap "TERM", stop_main_loop
					  Signal.trap "INT",  stop_main_loop

					  EventMachine.add_timer(self.watchdog_cycle) { watchdog }

					  EventHub.logger.info("Processor is listening to queue [#{[configuration.get('server.vhost'),configuration.get('processor.queue')].compact.join(".")}]")
					end
				rescue => e
					EventHub.logger.error("Unexpected exception: #{e}. Trying to restart in 5 seconds...")
					sleep 5
				end

			end # while

			EventHub.logger.info("Processor has been stopped")
		end

		def handle_message(metadata,payload)
			raise "Please implement method in derived class"
		end

		def handle_heartbeat(message)
			# sends a standard message back to dispatcher
		end

		def watchdog
			begin
				response = RestClient.get "http://#{self.user}:#{self.password}@#{hostname}:#{management_port}/api/queues/#{self.vhost}/#{self.queue_name}/bindings", { :content_type => :json}
  			data = JSON.parse(response.body)
  	
  			if response.code != 200
  				EventHub.logger.warn("Watchdog: Server did not answered properly. Trying to restart in 5 seconds...")
  				sleep 5
  				EventMachine.stop
  			elsif data.size == 0
  				EventHub.logger.warn("Watchdog: Something is wrong with the vhost, queue, and/or bindings. Trying to restart in 5 seconds...")
  				sleep 5
  				EventMachine.stop
  			else
  				# Watchdog is happy :-)
  			end

			rescue => e
				EventHub.logger.error("Watchdog: Unexpected exception: #{e}. Trying to restart in 5 seconds...")
				sleep 5
				EventMachine.stop
			end

			# place next time
			EventMachine.add_timer(watchdog_cycle) { watchdog }
		end

		def sent_to_dispatcher(payload)
			# send_connection = AMQP.connect({hostname: self.hostname, user: self.user, password: self.password, vhost: "event_hub"})
  		
  	# 	send_channel  = AMQP::Channel.new(send_connection)
  	# 	send_exchange = send_channel.direct("")

  	# 	send_exchange.publish payload, :routing_key => 'inbound'
		
			# send_channel.close
			# send_conncetion.close
		end

	end
end