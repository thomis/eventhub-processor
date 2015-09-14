module EventHub
  class Processor
    attr_reader :statistics, :name, :pidfile, :exception_writer

    include Helper

    def version
      '1.0.0'
    end

    def initialize(name=nil)
      @name = name || class_to_array(self.class)[1..-1].join('.')
      @pidfile = EventHub::Components::Pidfile.new(File.join(Dir.pwd, 'pids', "#{@name}.pid"))
      @exception_writer = EventHub::Components::ExceptionWriter.new
      @statistics = EventHub::Statistics.new
      @heartbeat = EventHub::Heartbeat.new(self)
      @message_processor = EventHub::MessageProcessor.new(self)

      @channel_receiver = nil
      @channel_sender   = nil
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

    def server_ssl?
      configuration.get('server.ssl') || false
    end

    def connection_settings
      { user: server_user, password: server_password, host: server_host, vhost: server_vhost }
    end

    def listener_queues
      Array(
        configuration.get('processor.listener_queue') ||
        configuration.get('processor.listener_queues') ||
        'undefined_listener_queues'
      )
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

    def start(detached = false)
      daemonize if detached

      EventHub.logger.info("Processor [#{@name}] base folder [#{Dir.pwd}]")

      # use timer here to have last heartbeat message working
      Signal.trap('TERM') { EventMachine.add_timer(0) { about_to_stop } }
      Signal.trap('INT')  { EventMachine.add_timer(0) { about_to_stop } }

      while @restart
        begin
          handle_start_internal

          # custom post start method to be overwritten
          post_start

        rescue => e
          id = @exception_writer.write(e)
          EventHub.logger.error("Unexpected exception: #{e}, see => #{id}. Trying to restart in #{self.restart_in_s} seconds...")
          sleep_break self.restart_in_s
        end
      end # while

      # custon post stop method to be overwritten
      post_stop

      EventHub.logger.info("Processor [#{@name}] has been stopped")
    ensure
      pidfile.delete
    end

    def handle_message(metadata, payload)
      raise 'Please implement method in derived class'
    end

    def call_service(method, url)
      if server_ssl?
        # ssl
        url = "https://" + url
        response = RestClient::Request.execute(method: method, url: url,
        ssl_ca_file: '/apps/sys_eventhub1/certs/cacert.pem',
        verify_ssl: OpenSSL::SSL::VERIFY_NONE,
          headers: {
            content_type: 'application/json',
            accept: 'application/json'
          }
        )
      else
        # no ssl
        url = "http://" + url
        response = RestClient::Request.execute(method: method, url: url,
          headers: {
            content_type: 'application/json',
            accept: 'application/json'
          }
        )
      end
      return response
    end

    def watchdog
      self.listener_queues.each do |queue_name|
        begin
          url = "#{self.server_user}:#{self.server_password}@#{self.server_host}:#{self.server_management_port}/api/queues/#{self.server_vhost}/#{queue_name}/bindings"
          response = call_service(:get, url)

          data = JSON.parse(response.body)

          if response.code != 200
            EventHub.logger.warn("Watchdog: Server did not answered properly. Trying to restart in #{self.restart_in_s} seconds...")
            EventMachine.add_timer(self.restart_in_s) { stop_processor(true) }
          elsif data.size == 0
            EventHub.logger.warn("Watchdog: Something is wrong with the vhost, queue [#{queue_name}], and/or bindings. Trying to restart in #{self.restart_in_s} seconds...")
            EventMachine.add_timer(self.restart_in_s) { stop_processor(true) }
            # does it make sense ? Needs maybe more checks in future
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
    end

    # send message
    def send_message(message, exchange_name = EventHub::EH_X_INBOUND)

      if @channel_sender.nil? || !@channel_sender.open?
        @channel_sender = AMQP::Channel.new(@connection, prefetch: 1)

        # use publisher confirm
        @channel_sender.confirm_select

        # @channel.on_error { |ch, channel_close| EventHub.logger.error "Oops! a channel-level exception: #{channel_close.reply_text}" }
        # @channel.on_ack   { |basic_ack| EventHub.logger.info "Received basic_ack: multiple = #{basic_ack.multiple}, delivery_tag = #{basic_ack.delivery_tag}" }
      end

      exchange = @channel_sender.direct(exchange_name, :durable => true, :auto_delete => false)
      exchange.publish(message.to_json, :persistent => true)
    end

    def sleep_break(seconds) # breaks after n seconds or after interrupt
      while (seconds > 0)
        sleep(1)
        seconds -= 1
        break unless @restart
      end
    end

    private

    def handle_start_internal
      AMQP.start(self.connection_settings) do |connection, open_ok|
        @connection = connection

        handle_connection_loss

        # create channel
        @channel_receiver = AMQP::Channel.new(@connection)
        @channel_receiver.prefetch(100)
        @channel_receiver.auto_recovery = true

        if @channel_receiver.auto_recovering?
          EventHub.logger.warn("Channel #{@channel_receiver.id} IS auto-recovering")
        end

        self.listener_queues.each do |queue_name|

          # connect to queue
          queue = @channel_receiver.queue(queue_name, durable: true, auto_delete: false)

          # subscribe to queue
          queue.subscribe(:ack => true) do |metadata, payload|
            begin
              statistics.measure(payload.size) do
                messages_to_send = @message_processor.process({ metadata: metadata, queue_name: queue_name}, payload)

                # ack message before publish
                metadata.ack

                # forward invalid or returned messages to dispatcher
                messages_to_send.each do |message|
                  send_message(message)
                end if messages_to_send


              end

            rescue EventHub::NoDeadletterException => e
              @channel_receiver.reject(metadata.delivery_tag, true)
              EventHub.logger.error("Unexpected exception in handle_message method: #{e}. Message will be requeued.")
              @exception_writer.write(e)
              sleep_break self.restart_in_s
            rescue => e
              @channel_receiver.reject(metadata.delivery_tag, false)
              EventHub.logger.error("Unexpected exception in handle_message method: #{e}. Message dead lettered.")
              @exception_writer.write(e)
            end
          end

        end

        EventHub.logger.info("Processor [#{@name}] is listening to vhost [#{self.server_vhost}], queues [#{self.listener_queues.join(', ')}]")

        register_timers

        # send first heartbeat
        heartbeat
      end
    end

    def handle_connection_loss
      @connection.on_tcp_connection_loss do |conn, settings|
        EventHub.logger.warn("Processor lost tcp connection. Trying to restart in #{self.restart_in_s} seconds...")
        conn.reconnect(false, self.restart_in_s)
      end
    end

    def register_timers
      EventMachine.add_timer(watchdog_cycle_in_s) { watchdog }
      EventMachine.add_periodic_timer(heartbeat_cycle_in_s) { heartbeat }
    end

    def heartbeat(action = 'running')
      message = @heartbeat.build_message(action)
      message.append_to_execution_history(@name)
      send_message(message)
    end

    def about_to_stop
      heartbeat('stopped')
      stop_processor
    end

    def stop_processor(restart=false)
      @restart = restart

      # close channels
      [@channel_receiver, @channel_sender].each do |channel|
        if channel
          channel.close if channel.open?
        end
      end

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

      @pidfile.write(Process.pid.to_s)
    end

    def post_start
      # method which can be overwritten to call a code sequence after reactor start
    end

    def post_stop
      # method which can be overwritten to call a code sequence after reactor stop
    end

  end
end
