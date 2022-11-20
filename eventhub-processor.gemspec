lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "eventhub/version"

Gem::Specification.new do |spec|
  spec.name = "eventhub-processor"
  spec.version = EventHub::VERSION
  spec.authors = ["Thomas Steiner"]
  spec.email = ["thomas.steiner@ikey.ch"]
  spec.description = "Gem to build Event Hub processors"
  spec.summary = "Gem to build Event Hub processors"
  spec.homepage = "http://github.com/thomis/eventhub-processor"
  spec.license = "MIT"

  spec.files = Dir["{lib}/**/*"] + ["LICENSE.txt"]
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rest-client", ">= 2.0.0"
  spec.add_runtime_dependency "amqp", ">= 1.6.0"
  spec.add_runtime_dependency "uuidtools", ">= 2.1.5"
  spec.add_runtime_dependency "eventhub-components", ">= 0.1.8"

  spec.add_development_dependency "bundler", ">= 1.12.5"
  spec.add_development_dependency "rake", ">= 11.2.2"
  spec.add_development_dependency "rspec", ">= 3.12.0"
  spec.add_development_dependency "rspec-mocks", "~> 3.12.0"
  spec.add_development_dependency "standard", "1.18"
  spec.add_development_dependency "simplecov", "~> 0.21"
end
