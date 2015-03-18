require 'spec_helper'

describe EventHub::MessageProcessor do

  let(:message_processor) {
    processor = double(:processor)
    allow(processor).to receive(:name).and_return('a.processor', 'b.processor')
    allow(processor).to receive(:handle_message) do |message|
      message
    end
    EventHub::MessageProcessor.new(processor)
  }


  it 'forwards the message to the processor' do
    message_processor.process(Object.new, '{}')
    expect(message_processor.processor).to have_received(:handle_message)
  end

  it 'adds execution history to header' do
    allow_any_instance_of(EventHub::Message).to receive(:now_stamp).and_return('a.stamp')
    response = message_processor.process(Object.new, '{}')
    execution_history = response[0].header.get('execution_history')
    expect(execution_history.size).to eq(1)
    expect(execution_history[0]).to eq({'processor' => 'a.processor', 'timestamp' => 'a.stamp'})
  end

  it 'appends execution history to header' do
    allow_any_instance_of(EventHub::Message).to receive(:now_stamp).and_return('a.stamp')
    response = message_processor.process(Object.new, '{}')
    message = response[0]

    allow_any_instance_of(EventHub::Message).to receive(:now_stamp).and_return('b.stamp')
    response = message_processor.process(Object.new, message.to_json)
    puts response
    execution_history =  response[0].header.get('execution_history')

    expect(execution_history.size).to eq(2)
    expect(execution_history[0]).to eq({'processor' => 'a.processor', 'timestamp' => 'a.stamp'})
    expect(execution_history[1]).to eq({'processor' => 'b.processor', 'timestamp' => 'b.stamp'})
  end

  it 'should handle message payload as an array' do
    messages = []
    message = EventHub::Message.new
    messages << message.to_json

    message = EventHub::Message.new
    messages << message.to_json

    response = message_processor.process(Object.new, messages)
    expect(response.size).to eq(2)
    #puts response.size
  end

end
