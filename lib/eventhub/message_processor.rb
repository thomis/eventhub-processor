class EventHub::MessageProcessor
  attr_reader :processor

  def initialize(processor)
    @processor = processor
  end

  def process(params, payload)
    messages_to_send = []

    # check if payload is an array
    if payload.is_a?(Array)
      payload.each do |one_message|
        messages_to_send << handle(params, one_message)
      end
    else
      messages_to_send = handle(params, payload)
    end

    messages_to_send
  end

  private

  def handle(params, payload)
    # try to convert to EventHub message
    message = EventHub::Message.from_json(payload)
    EventHub.logger.info("-> #{message}")

    message.append_to_execution_history(processor.name)

    if message.invalid?
      messages_to_send << message
      EventHub.logger.info("-> #{message} => Put to queue [#{EventHub::EH_X_INBOUND}].")
    elsif processor.method(:handle_message).arity == 1
      # pass received message to handler or dervied handler
      messages_to_send = Array(processor.handle_message(message))
    else
      messages_to_send = Array(processor.handle_message(message, params))
    end
    messages_to_send
  end
end
