# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mqtt_pipe/version'

Gem::Specification.new do |spec|
  spec.name          = "mqtt_pipe"
  spec.version       = MQTTPipe::VERSION
  spec.authors       = ["Sebastian Lindberg"]
  spec.email         = ["seb.lindberg@gmail.com"]
  spec.summary       = %q{A gem for sending a small set of objects via MQTT.}
  spec.description   = %q{This gem wraps the MQTT gem by njh (on Github) and adds a serializer for simple data structures.}
  spec.homepage      = "https://github.com/seblindberg/ruby-mqtt-pipe"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mqtt", "~> 0.3"
  
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
end
