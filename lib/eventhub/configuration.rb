module EventHub
  class Configuration
    include Singleton
    include Helper

    attr_accessor :data, :folder, :environment

    def initialize
      @data = {}
      @environment = "development"
    end

    def load_file(input, env = "development")
      load_string(IO.read(input), env)
      true
    rescue => e
      EventHub.logger.info("Unexpected exception while loading configuration [#{input}]: #{format_string(e.message)}")
      false
    end

    def load_string(json_string, env = "development")
      json = JSON.parse(json_string)
      @data = json[env]
      @environment = env
      true
    rescue => e
      EventHub.logger.info("JSON configuration parsing failed: #{format_string(e.message)}")
      false
    end
  end
end
