module Pluginizer
  class PluginBuilder < Rails::PluginBuilder
    def readme
      template 'README.md'
    end

    def gemspec
      template "%name%.gemspec"
    end

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

      gsub_file 'spec/rails_helper.rb',
        "require File.expand_path('../../config/environment', __FILE__)",
        "require File.expand_path('../dummy/config/environment', __FILE__)"

      run "bundle binstubs rspec-core"

      { "# Add additional requires below this line. Rails is not loaded until this point!" =>
          "\nrequire 'fantaskspec'\n",
        %{# config.filter_gems_from_backtrace("gem name")} =>
          "\n\n  config.infer_rake_task_specs_from_file_location!"
      }.each do |after_line, new_line|
        insert_into_file 'spec/rails_helper.rb', new_line, after: after_line
      end
    end
  end
end
