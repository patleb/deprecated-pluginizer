# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pluginizer/version'

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= #{Pluginizer::RUBY_VERSION}"

  spec.name          = "pluginizer"
  spec.version       = Pluginizer::VERSION
  spec.authors       = ["Patrice Lebel"]
  spec.email         = ["patleb@users.noreply.github.com"]

  spec.summary       = "Plugin Boilerplate Builder"
  spec.description   = "Plugin Boilerplate Builder"
  spec.homepage      = "https://github.com/patleb/pluginizer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["pluginizer"]
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', "~> #{Pluginizer::RAILS_VERSION}", ">= #{Pluginizer::RAILS_VERSION}.0"

  spec.add_runtime_dependency 'bundler', '~> 1.3'

  spec.add_development_dependency "rake", "~> 10.0"
end
