require 'spec_helper'

describe EventHub::ArgumentParser do
  it 'sets defaults' do
    parsed = EventHub::ArgumentParser.parse([])
    expect(parsed.environment).to eq('development')
    expect(parsed.detached).to eq(false)
  end

  it 'parses environment' do
    parsed = EventHub::ArgumentParser.parse(['--environment=foo'])
    expect(parsed.environment).to eq('foo')
    expect(parsed.detached).to eq(false)
  end

  it 'parses detached' do
    parsed = EventHub::ArgumentParser.parse(['-d'])
    expect(parsed.environment).to eq('development')
    expect(parsed.detached).to eq(true)
  end
end