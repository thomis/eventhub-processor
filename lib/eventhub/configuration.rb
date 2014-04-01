module EventHub

	class Configuration
		include Singleton

		attr_accessor :data
  	
  	def initialize
    	@data = nil
  	end

  	def load_file(input, env='development')
    	tmp = JSON.parse( IO.read(input))
  		@data = tmp[env]
  	end

	end

end