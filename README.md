[![Gem Version](https://badge.fury.io/rb/eventhub-processor.svg)](https://badge.fury.io/rb/eventhub-processor)
[![Maintainability](https://api.codeclimate.com/v1/badges/180d049db38b0100662d/maintainability)](https://codeclimate.com/github/thomis/eventhub-processor/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/180d049db38b0100662d/test_coverage)](https://codeclimate.com/github/thomis/eventhub-processor/test_coverage)
[![ci](https://github.com/thomis/eventhub-processor/actions/workflows/ci.yml/badge.svg)](https://github.com/thomis/eventhub-processor/actions/workflows/ci.yml)


## Important information from 2022-07-27

This component has been replaced by https://github.com/thomis/eventhub-processor2 and will no longer be maintained. Please upgrade to new processor2 gem.


eventhub-processor
=================

Gem to build Event Hub Processors. It gives you some core infrastructure pieces to easily implement a customized Event Hub Processor.

## Installation

Add this line to your application's Gemfile:

    gem 'eventhub-processor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eventhub-processor

## Usage

The easiest way to cretae a new processor is to use the _eventhub-command_ gem. Run

```
eh generate_processor --help
```
for details.


### Code

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


## Arguments

You can use the default argument parser behaviour (-e, -d, -h) or extend it like:

```
parsed = EventHub::ArgumentParser.parse(['-x']) do |parser, options|
  parser.on('-x') do
    options.x = 'secret switch selected'
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

