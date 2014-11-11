require 'spec_helper'

describe EventHub::Heartbeat do
  before(:each) do
    EventHub::Configuration.instance.data = {}
  end

  let(:processor) { EventHub::Processor.new }
  let(:heartbeat) { EventHub::Heartbeat.new(processor) }


  it 'builds the message' do
    message = heartbeat.build_message
    expect(message.process_name).to eq("event_hub.heartbeat")
  end


end