module EventHub

	class Configuration
		include Singleton
    include Helper

		attr_accessor :data, :folder, :environment
  	
  	def initialize
    	@data = nil
      @folder = Dir.pwd
      @environment = 'development'
  	end

  	def load_file(input, env='development')
    	tmp = JSON.parse( IO.read(input))
  		@data = tmp[env]
      @environment = env
      true
    rescue => e
      EventHub.logger.info("Unexpected exception while loading configuration [#{input}]: #{format_string(e.message)}")
  	  false
    end

	end

end