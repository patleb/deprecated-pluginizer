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
      configure_gemfile

      after_bundle do
        in_root do
          configure_database_yml if options.database == 'postgresql'
          configure_rspec
          configure_dummy_environments

          if options.assets_only?
            copy_file 'Bowerfile'
            insert_into_file 'Rakefile', "\n\nRails.application.load_tasks",
              after: "require 'bundler/gem_tasks'"
            inside 'app' do
              remove_dir 'assets/config'
              remove_dir 'assets/images'
              remove_dir 'controllers'
              remove_dir 'helpers'
              remove_dir 'mailers'
              remove_dir 'models'
              remove_dir 'views'
            end
            remove_dir 'bin'
            remove_dir 'config'
            remove_dir 'lib/tasks'
            remove_file "lib/#{namespaced_name}/configuration.rb"
            inside 'spec' do
              remove_file 'rails_helper.rb'
              remove_file 'spec_helper.rb'
              inside 'dummy' do
                remove_dir 'app'
                remove_dir 'bin'
                inside 'config' do
                  remove_dir 'environments'
                  remove_dir 'initializers'
                  remove_dir 'locales'
                  remove_file 'cable.yml'
                  remove_file 'database.yml'
                  remove_file 'environment.rb'
                  remove_file 'puma.rb'
                  remove_file 'routes.rb'
                  remove_file 'secrets.yml'
                  remove_file 'spring.rb'
                end
                remove_dir 'db'
                remove_dir 'lib'
                remove_dir 'log'
                remove_dir 'public'
                remove_dir 'tmp'
                remove_file 'config.ru'
              end
            end
          end

          unless options.skip_git? || options.skip_git_init?
            git :init
            git add: '.'
            git commit: "-m 'first commit'"
            git remote: "add origin git@github.com:patleb/#{name}.git"
            git push: "-u origin master"
          end
        end
      end
    end

    private

    def configure_gemfile
      insert_into_file 'Gemfile', <<-END.strip_heredoc, after: "source 'https://rubygems.org'"
        \n
        git_source(:github) do |repo_name|
          repo_name = "\#{repo_name}/\#{repo_name}" unless repo_name.include?("/")
          "https://github.com/\#{repo_name}.git"
        end
      END
    end

    def configure_database_yml
      insert_into_file 'spec/dummy/config/database.yml', <<-END.strip_heredoc.indent(2), after: "encoding: unicode"

        host: 127.0.0.1
        username: postgres
        password: postgres
      END
    end

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
      insert_into_file rails_helper, "\n#{requires}\n",
        after: "# Add additional requires below this line. Rails is not loaded until this point!"

      insert_into_file rails_helper, "\n  config.infer_rake_task_specs_from_file_location!\n",
        before: /^end/
      insert_into_file rails_helper, "\n  config.render_views\n",
        before: /^end/
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
      insert_into_file rails_helper, "\n  config.include(Shoulda::Callback::Matchers::ActiveModel)\n",
        before: /^end/
    end

    def configure_dummy_environments
      insert_into_file 'spec/dummy/config/environments/test.rb', <<-END.strip_heredoc.indent(2), before: /^end/

        config.logger = ActiveSupport::Logger.new(config.paths['log'].first, 1, 5*1024*1024) # 5Mb
      END
    end
  end
end
