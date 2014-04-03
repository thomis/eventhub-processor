module EventHub

	class Configuration
		include Singleton
    include Helper

		attr_accessor :data
  	
  	def initialize
    	@data = nil
  	end

  	def load_file(input, env='development')
    	tmp = JSON.parse( IO.read(input))
  		@data = tmp[env]
      true
    rescue => e
      EventHub.logger.info("Unexpected exception while loading configuration [#{input}]: #{format_raw_string(e.message)}")
  	  false
    end

	end

end