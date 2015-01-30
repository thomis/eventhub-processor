require 'bundler/setup'
Bundler.setup

require 'eventhub-processor'

RSpec.configure do |config|
  config.mock_with :rspec
end
