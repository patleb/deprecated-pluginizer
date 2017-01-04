require 'rails/generators'
require 'rails/generators/rails/plugin/plugin_generator'

module Pluginizer
  class PluginGenerator < Rails::Generators::PluginGenerator
    class_option :dummy_path, type: :string, default: "spec/dummy",
      desc: "Create dummy application at given path"

    class_option :full, type: :boolean, default: true,
      desc: "Generate a rails engine with bundled Rails application for testing"

    class_option :ruby_version, type: :string, default: '2.3.1',
      desc: 'Set Ruby version used'

    class_option :skip_git_init, type: :boolean, default: false,
      desc: 'Skip git repository initialization'

    protected

    def get_builder_class
      Pluginizer::PluginBuilder
    end
  end
end
