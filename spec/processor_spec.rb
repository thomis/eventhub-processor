require "spec_helper"

describe EventHub::Processor do
  before(:each) do
    @configuration = EventHub::Configuration.instance.data = {
    }
  end

  let(:processor) { EventHub::Processor.new }

  it "should have ssl disabled by default" do
    expect(processor.server_ssl?).to eq(false)
  end

  it "should be possible to enable ssl via configuration" do
    @configuration.set("server.ssl", true)
    expect(processor.server_ssl?).to eq(true)
  end

  it "should return default ssl settings" do
    expect(processor.ssl_settings).to eq({})
  end

  it "should return enabled ssl settings" do
    @configuration.set("server.ssl", true)
    expect(processor.ssl_settings).to eq({cert_chain_file: nil, private_key_file: nil})
  end

  it "should return default port" do
    expect(processor.server_port).to eq(5672)
  end

  it "should return custom port" do
    @configuration.set("server.port", 1000)
    expect(processor.server_port).to eq(1000)
  end

  # it 'does something' do
  #  metadata = double(:metadata, :delivery_tag => 'abcde')
  #  payload = "{}"
  #  queue = double(:queue)
  #  queue.stub(:subscribe).and_yield(metadata, payload)
  #  channel = double(:channel, :queue => queue, :acknowledge => true, :prefetch => 100, :auto_recovery => true)
  #  processor.stub(:register_timers)
  #  processor.stub(:handle_connection_loss)
  #  processor.stub(:handle_message)
  #  AMQP.stub(:start).and_yield(nil, nil)
  #  AMQP::Channel.stub(:new).and_return(channel)
  #
  #  processor.start
  # end
end
