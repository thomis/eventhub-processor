require 'amqp'
require 'rest-client'
require 'json'
require 'singleton'
require 'uuidtools'
require 'base64'
require 'socket'
require 'ostruct'
require 'optparse'

begin
  require 'pry'
rescue
end

require_relative 'eventhub/argument_parser'
require_relative 'eventhub/version'
require_relative 'eventhub/constant'
require_relative 'eventhub/helper'
require_relative 'eventhub/multi_logger'

require_relative 'eventhub/configuration'
require_relative 'eventhub/hash_extensions'
require_relative 'eventhub/statistics'
require_relative 'eventhub/heartbeat'
require_relative 'eventhub/pidfile'
require_relative 'eventhub/processor'
require_relative 'eventhub/message_processor'
require_relative 'eventhub/message'


module EventHub
  def self.logger
  	unless @logger
  		@logger = MultiLogger.new
      @logger.add_device(Logger.new(STDOUT))
  	end
  	@logger
  end
end