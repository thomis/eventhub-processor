# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eventhub/version'

Gem::Specification.new do |spec|
  spec.name          = "eventhub-processor"
  spec.version       = EventHub::VERSION
  spec.authors       = ["Thomas Steiner"]
  spec.email         = ["thomas.steiner@ikey.ch"]
  spec.description   = %q{Gem to build Event Hub processors}
  spec.summary       = %q{Gem to build Event Hub processors}
  spec.homepage      = "http://github.com/thomis/eventhub-processor"
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*"] + ["LICENSE.txt"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "amqp"
  spec.add_runtime_dependency "uuidtools"
end
