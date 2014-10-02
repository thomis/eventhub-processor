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

  spec.add_development_dependency "bundler", '>= 1.3.0'
  spec.add_development_dependency "rake", "~> 10.3.0", '>= 10.3.0'
  spec.add_development_dependency "rspec", "~> 3.0.0", '>= 3.0.0'
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "rest-client", "~> 1.7.2", '>= 1.7.2'
  spec.add_runtime_dependency "amqp", "~> 1.5.0", '>= 1.5.0'
  spec.add_runtime_dependency "uuidtools", "~> 2.1", '>= 2.1'
end
