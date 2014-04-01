eventhub-processor
=================

Gem to build Event Hub processor

## Installation

Add this line to your application's Gemfile:

    gem 'eventhub-processor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eventhub-processor

## Usage

```Ruby
# define a class and derive it from Eventhub::Processor
module EventHub
	class PlateStoreRouter < Processor
		# this is the method to deal with the message
		def handle_message(metadata,payload)
			puts payload
		end
	end
end

# load configuration file if required and start your processor
config_file = ['config',"#{File.basename(__FILE__,'.rb')}.json"].join('/')
EventHub::Configuration.instance.load_file(config_file,environment)

# create instance of your processor and start it
EventHub::PlateStoreRouter.new.start
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

