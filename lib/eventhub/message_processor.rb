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

    append_to_trail(message)

    if message.invalid?
      messages_to_send << message
      EventHub.logger.info("-> #{message.to_s} => Put to queue [#{EH_X_INBOUND}].")
    else
      # pass received message to handler or dervied handler
      response = processor.handle_message(metadata, message)
      messages_to_send = Array(response)
    end

    messages_to_send
  end

  private

  def append_to_trail(message)
    unless message.header.get('execution_path')
      message.header.set('execution_path', [])
    end
    message.header.get('execution_path') << {'processor' => self.processor.name, 'timestamp' => processor.now_stamp}
  end
end