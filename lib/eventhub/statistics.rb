class EventHub::Statistics
  attr_reader :messages_successful, :messages_unsuccessful, :messages_average_size, :messages_average_process_time

  def initialize
    @messages_successful = 0
    @messages_unsuccessful = 0
    @messages_average_size = 0
    @messages_average_process_time = 0
    @messages_total_process_time = 0
  end

  def measure(size, &block)
    start = Time.now
    yield
    success(Time.now - start, size)
  rescue
    failure
    raise
  end

  def success(process_time, size)
    @messages_total_process_time += process_time
    @messages_average_process_time = (messages_total_process_time + process_time) / (messages_successful + 1).to_f
    @messages_average_size = (messages_total_size + size) / (messages_successful + 1).to_f
    @messages_successful += 1
  end

  def failure
    @messages_unsuccessful += 1
  end

  def messages_total
    messages_unsuccessful + messages_successful
  end

  def messages_total_process_time
    messages_average_process_time * messages_successful
  end

  def messages_total_size
    messages_average_size * messages_successful
  end
end
