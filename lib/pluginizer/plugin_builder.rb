module Pluginizer
  class PluginBuilder < Rails::PluginBuilder
    def gitignore
      template '.gitignore'
    end

    def test
    end

    def leftovers
      template '.ruby-version'
      template "lib/%namespaced_name%/configuration.rb"

      after_bundle do
        in_root do
          configure_rspec

          git :init
          git add: '.'
          git commit: "-m 'first commit'"
        end
      end
    end

    private

    def configure_rspec
      invoke('rspec:install')
      rails_helper = 'spec/rails_helper.rb'

      gsub_file rails_helper,
        "require File.expand_path('../../config/environment', __FILE__)",
        "require File.expand_path('../dummy/config/environment', __FILE__)"
      gsub_file rails_helper,
        %{config.fixture_path = "\#{::Rails.root}/spec/fixtures"},
        %{config.fixture_path = "\#{#{camelized}::Engine.root}/spec/fixtures"}

      run "bundle binstubs rspec-core"

      requires = %w[
        fantaskspec
        email_spec
        email_spec/rspec
      ].map{ |file| "require '#{file}'" }.join("\n")
      insert_into_file rails_helper, "\n#{requires}\n", after: "# Add additional requires below this line. Rails is not loaded until this point!"

      insert_into_file rails_helper, "\n  config.infer_rake_task_specs_from_file_location!\n", before: /^end/
      insert_into_file rails_helper, "\n  config.render_views\n", before: /^end/
      insert_into_file rails_helper, <<-END.strip_heredoc.indent(2), before: /^end/

        config.before(:each) do
          Rails.cache.clear
        end
      END
      insert_into_file rails_helper, <<-END.strip_heredoc.indent(2), before: /^end/

        Shoulda::Matchers.configure do |config|
          config.integrate do |with|
            with.test_framework :rspec
            with.library :rails
          end
        end
      END
      insert_into_file rails_helper, "\n  config.include(Shoulda::Callback::Matchers::ActiveModel)\n", before: /^end/
    end
  end
end
