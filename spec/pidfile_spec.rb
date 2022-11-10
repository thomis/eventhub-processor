require "spec_helper"
require "fileutils"

describe EventHub::Components::Pidfile do
  before(:each) do
    FileUtils.remove_dir("/tmp/eventhub_pid_test", true)
  end

  after(:each) do
    FileUtils.remove_dir("/tmp/eventhub_pid_test", true)
  end

  let(:pidfile) { EventHub::Components::Pidfile.new("/tmp/eventhub_pid_test/some.pid") }

  it "creates the folders if not existing" do
    pidfile.write(1234)
    expect(File.directory?("/tmp/eventhub_pid_test")).to be true
  end

  it "writes the content to the file" do
    pidfile.write(1234)
    expect(IO.read("/tmp/eventhub_pid_test/some.pid")).to eq("1234")
  end

  it "deletes the file" do
    pidfile.write(1234)
    pidfile.delete
    expect(File.file?("/tmp/eventhub_pid_test/some.pid")).to be false
  end

  it "does not choke when deleting a non-existing pid file" do
    pidfile.delete
  end
end
