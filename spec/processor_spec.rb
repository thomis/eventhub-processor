require 'spec_helper'

describe EventHub::Processor do
  # before(:each) do
  #   EventHub::Configuration.instance.data = {}

  # end

  # let(:processor) { EventHub::Processor.new }

  # it 'does something' do
  #   metadata = double(:metadata, :delivery_tag => 'abcde')
  #   payload = "{}"
  #   queue = double(:queue)
  #   queue.stub(:subscribe).and_yield(metadata, payload)
  #   channel = double(:channel, :queue => queue, :acknowledge => true)
  #   processor.stub(:register_timers)
  #   processor.stub(:handle_connection_loss)
  #   processor.stub(:handle_message)
  #   AMQP.stub(:start).and_yield(nil, nil)
  #   AMQP::Channel.stub(:new).and_return(channel)

  #   processor.start
  # end



end
