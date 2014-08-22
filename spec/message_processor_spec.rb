require 'spec_helper'

describe EventHub::MessageProcessor do

  let(:message_processor) {
    processor = double(:processor)
    allow(processor).to receive(:name).and_return('a.processor', 'b.processor')
    allow(processor).to receive(:now_stamp).and_return('a.stamp', 'b.stamp')
    allow(processor).to receive(:handle_message) do |metadata, message|
      message
    end
    EventHub::MessageProcessor.new(processor)
  }


  it 'forwards the message to the processor' do
    message_processor.process(Object.new, '{}')
    expect(message_processor.processor).to have_received(:handle_message)
  end

  it 'adds execution path to header' do
    response = message_processor.process(Object.new, '{}')
    message = response[0]
    expect(message.header.get('execution_path').size).to eq(1)
    expect(message.header.get('execution_path')[0]).to eq({'processor' => 'a.processor', 'timestamp' => 'a.stamp'})
  end

  it 'appends execution path to header' do
    response = message_processor.process(Object.new, '{}')
    message = response[0]

    response = message_processor.process(Object.new, message.to_json)
    message = response[0]

    expect(message.header.get('execution_path').size).to eq(2)
    expect(message.header.get('execution_path')[0]).to eq({'processor' => 'a.processor', 'timestamp' => 'a.stamp'})
    expect(message.header.get('execution_path')[1]).to eq({'processor' => 'b.processor', 'timestamp' => 'b.stamp'})
  end

end