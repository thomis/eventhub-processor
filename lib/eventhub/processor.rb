module EventHub
	class Processor

		def configuration
			EventHub::Configuration.instance.data
		end

		def start

			AMQP.start(configuration.get('server')) do |connection, open_ok|
				
				# create channel
				channel = AMQP::Channel.new(connection)
		  	channel.auto_recovery = true
		  
		  	# connect to queue
		  	queue = channel.queue(configuration.get('processor.queue'), durable: true, auto_delete: false)

		  	# subscribe to queue
			  queue.subscribe do |metadata, payload|

			  	handle_heartbeat(message)

			  	handle_message(metadata,payload)
			  end

				# Features to stop main event loop
				stop_main_loop = Proc.new {
			    connection.disconnect { 
			    	EventMachine.stop
			    	restart = false
			    }
		  	}

			  Signal.trap "TERM", stop_main_loop
			  Signal.trap "INT",  stop_main_loop

			  EventMachine.add_timer(configuration.get('processor.watchdog_cycle')) { watchdog }

			end
		end

		def handle_message(metadata,payload)
			raise "Please implement method in derived class"
		end

		def handle_heartbeat(message)
			# sends a standard message back to dispatcher
		end

		def watchdog
			puts "watchdog"
			EventMachine.add_timer(configuration.get('processor.watchdog_cycle')) { watchdog }
		end

		def sent_to_inbound(message)

		end

	end
end