class EventHub::Heartbeat
  include ::EventHub::Helper

  attr_reader :processor, :statistics, :started_at

  def initialize(processor)
    @started_at = Time.now
    @processor = processor
    @statistics = @processor.statistics
  end


  def build_message(action="running")
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
      heartbeat: {
        started:                now_stamp(started_at),
        stamp_last_beat:        now_stamp(now),
        uptime:                 duration(now - started_at),
        heartbeat_cycle_in_s:   processor.heartbeat_cycle_in_s,
        served_queues:          [processor.listener_queue],
        host:                   get_host,
        ip_adresses:            get_ip_adresses,
        messages: {
          total:                statistics.messages_total,
          successful:           statistics.messages_successful,
          unsuccessful:         statistics.messages_unsuccessful,
          average_size:         statistics.messages_average_size,
          average_process_time: statistics.messages_average_process_time
        }
      }
    }
    message
  end


end