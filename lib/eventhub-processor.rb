require 'amqp'
require 'rest-client'
require 'json'
require 'singleton'
require 'uuidtools'
require 'base64'
require 'socket'

require_relative 'eventhub/version'
require_relative 'eventhub/constant'
require_relative 'eventhub/helper'
require_relative 'eventhub/multi_logger'

require_relative 'eventhub/configuration'
require_relative 'eventhub/hash_extensions'
require_relative 'eventhub/processor'
require_relative 'eventhub/message'

module EventHub
  def self.logger
  	unless @logger
  		a = Logger.new(STDOUT)
  		@logger = MultiLogger.new(a)
  	end
  	@logger
  end
end