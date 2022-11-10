require "spec_helper"

describe EventHub::ArgumentParser do
  it "sets defaults" do
    parsed = EventHub::ArgumentParser.parse([])
    expect(parsed.environment).to eq("development")
    expect(parsed.detached).to eq(false)
  end

  it "parses environment" do
    parsed = EventHub::ArgumentParser.parse(["--environment=foo"])
    expect(parsed.environment).to eq("foo")
    expect(parsed.detached).to eq(false)
  end

  it "parses envrionment with single character option" do
    parsed = EventHub::ArgumentParser.parse(["--e=foo"])
    expect(parsed.environment).to eq("foo")
    expect(parsed.detached).to eq(false)
  end

  it "parses detached" do
    parsed = EventHub::ArgumentParser.parse(["-d"])
    expect(parsed.environment).to eq("development")
    expect(parsed.detached).to eq(true)
  end

  it "allows to extend parsing through a block" do
    parsed = EventHub::ArgumentParser.parse(["-x"]) do |parser, options|
      parser.on("-x") do
        options.x = "jada"
      end
    end
    expect(parsed.x).to eq("jada")
  end
end
