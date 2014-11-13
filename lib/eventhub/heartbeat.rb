module EventHub

  class Heartbeat
    include Helper

    attr_reader :processor, :statistics, :started_at

    def initialize(processor)
      @started_at = Time.now
      @processor = processor
      @statistics = @processor.statistics
    end


    def build_message(action = "running")
      message = ::EventHub::Message.new
      message.origin_module_id  = processor.name
      message.origin_type       = "processor"
      message.origin_site_id    = 'global'

      message.process_name      = 'event_hub.heartbeat'

      now = Time.now

      # message structure needs more changes
      message.body = {
        version: processor.version,
        action:  action,
        pid:     Process.pid,
        process_name: 'event_hub.heartbeat',

        heartbeat: {
          started:                      now_stamp(started_at),
          stamp_last_beat:              now_stamp(now),
          uptime_in_ms:                 (now - started_at)*1000,
          heartbeat_cycle_in_ms:        processor.heartbeat_cycle_in_s * 1000,
          queues_consuming_from:        processor.listener_queues,
          queues_publishing_to:         ['event_hub.inbound'], # needs more dynamic in the future
          host:                         Socket.gethostname,
          addresses:                    addresses,
          messages: {
            total:                      statistics.messages_total,
            successful:                 statistics.messages_successful,
            unsuccessful:               statistics.messages_unsuccessful,
            average_size:               statistics.messages_average_size,
            average_process_time_in_ms: statistics.messages_average_process_time*1000,
            total_prozess_time_in_ms:   statistics.messages_total_process_time*1000
          }
        }
      }
      message
    end

    private

    def addresses
      interfaces = Socket.getifaddrs.select do |interface|
        !interface.addr.ipv4_loopback? && !interface.addr.ipv6_loopback?
      end

      interfaces.map do |interface|
        begin
          {
            :interface => interface.name,
            :host_name => Socket.gethostname,
            :ip_address => interface.addr.ip_address
          }
        rescue
          nil # will be ignored
        end
      end.compact

    end

  end

end
