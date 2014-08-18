require 'spec_helper'

describe EventHub::Statistics do
  let(:statistics) { EventHub::Statistics.new }

  it 'increments the successful message counter' do
    expect { statistics.success(0, 0) }.to change { statistics.messages_successful }
  end

  it 'increments the unsuccessful message counter' do
    expect { statistics.failure }.to change { statistics.messages_unsuccessful }
  end

  it 'calculates the average size' do
    expect(statistics.messages_average_size).to eq(0)

    statistics.success(0, 10)
    expect(statistics.messages_average_size).to eq(10.0)

    statistics.success(0, 30)
    expect(statistics.messages_average_size).to eq(20.0)

    statistics.success(0, 15)
    expect(statistics.messages_average_size).to eq(55 / 3.0)
  end

  it 'calculates the average process time' do
    expect(statistics.messages_average_process_time).to eq(0)

    statistics.success(10, 0)
    expect(statistics.messages_average_process_time).to eq(10.0)

    statistics.success(30, 0)
    expect(statistics.messages_average_process_time).to eq(20.0)

    statistics.success(15, 0)
    expect(statistics.messages_average_process_time).to eq(55 / 3.0)
  end

end