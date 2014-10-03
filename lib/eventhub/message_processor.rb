class EventHub::MessageProcessor
  attr_reader :processor

  def initialize(processor)
    @processor = processor
  end

  def process(metadata, payload)
    messages_to_send = []

    # try to convert to EventHub message
    message = EventHub::Message.from_json(payload)
    EventHub.logger.info("-> #{message.to_s}")

    message.append_to_execution_history(self.processor.name)

    if message.invalid?
      messages_to_send << message
      EventHub.logger.info("-> #{message.to_s} => Put to queue [#{EventHub::EH_X_INBOUND}].")
    else
      # pass received message to handler or dervied handler
      response = processor.handle_message(message)
      messages_to_send = Array(response)
    end

    messages_to_send
  end
end