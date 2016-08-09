module Pluginizer
  class PluginBuilder < Rails::PluginBuilder
    def readme
      template 'README.md'
    end

    def gemspec
      template "%name%.gemspec"
    end

    def test
    end

    def leftovers
      template '.ruby-version'

      after_bundle do
        git :init
        git add: '.'
        git commit: "-m 'first commit'"
      end
    end
  end
end
