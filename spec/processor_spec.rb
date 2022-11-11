require "spec_helper"

describe EventHub::Processor do
  before(:each) do
    @configuration = EventHub::Configuration.instance.data = {}
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

  it "should return default host" do
    expect(processor.server_host).to eq("localhost")
  end

  it "should return custom host" do
    @configuration.set("server.host", "whatever")
    expect(processor.server_host).to eq("whatever")
  end

  it "should return default port" do
    expect(processor.server_port).to eq(5672)
  end

  it "should return custom port" do
    @configuration.set("server.port", 1000)
    expect(processor.server_port).to eq(1000)
  end

  it "should return default user" do
    expect(processor.server_user).to eq("admin")
  end

  it "should return custom user" do
    @configuration.set("server.user", "user")
    expect(processor.server_user).to eq("user")
  end

  it "should return default password" do
    expect(processor.server_user).to eq("admin")
  end

  it "should return custom password" do
    @configuration.set("server.password", "secret")
    expect(processor.server_password).to eq("secret")
  end

  it "should return default management port" do
    expect(processor.server_management_port).to eq(15672)
  end

  it "should return custom management port" do
    @configuration.set("server.management_port", 1000)
    expect(processor.server_management_port).to eq(1000)
  end

  it "should return default vhost" do
    expect(processor.server_vhost).to eq("event_hub")
  end

  it "should return custom vhost" do
    @configuration.set("server.vhost", "virtual")
    expect(processor.server_vhost).to eq("virtual")
  end

  it "should return default connection settings" do
    expect(processor.connection_settings).to eq(
      {host: "localhost", user: "admin", password: "admin", port: 5672, vhost: "event_hub"}
    )
  end

  it "should return default listener queues" do
    expect(processor.listener_queues).to eq(["undefined_listener_queues"])
  end

  it "should return default watchdog_cycle_in_s" do
    expect(processor.watchdog_cycle_in_s).to eq(15)
  end

  it "should return default restart_in_s" do
    expect(processor.restart_in_s).to eq(15)
  end

  it "should raise when handle_message is not defined" do
    expect { processor.handle_message(nil, nil) }.to raise_error(RuntimeError, "Please implement method in derived class")
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
