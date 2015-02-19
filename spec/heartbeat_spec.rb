require 'spec_helper'

describe EventHub::Heartbeat do
  before(:each) do
    EventHub::Configuration.instance.data = {}
  end

  let(:processor) { EventHub::Processor.new }
  let(:heartbeat) { EventHub::Heartbeat.new(processor) }


  it 'builds the message' do
    message = heartbeat.build_message

    expect(message.process_name).to     eq('event_hub.heartbeat')
    expect(message.origin_module_id).to eq('processor')
    expect(message.origin_type).to      eq('processor')
    expect(message.origin_site_id).to   eq('global')

    expect(message.body).to be_a(Array)
    expect(message.body.size).to eq(1)
  end


end
