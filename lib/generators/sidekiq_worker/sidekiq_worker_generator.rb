# lib/generators/sidekiq_worker/sidekiq_worker_generator.rb
require_relative "../shared/helpers"
module SidekiqWorker
  class SidekiqWorkerGenerator < Rails::Generators::NamedBase
    include GeneratorHelpers
    source_root File.expand_path("templates", __dir__)
    desc "Generates a Sidekiq worker and its test"

    def create_worker_file
      template "worker.rb.tt", File.join("app/workers", class_path, "#{file_name}.rb")
      if behavior == :invoke
        setup_sidekiq
      elsif behavior == :revoke
        remove_sidekiq_setup_if_last_worker
      end
    end

    def create_test_file
      template "worker_test.rb.tt", File.join("test/workers", class_path, "#{file_name}_test.rb")
    end

    def setup_sidekiq
      return if behavior == :revoke  # Do nothing if destroying
      # Add sidekiq gems
      safe_add_gem("sidekiq")
      safe_add_gem("sidekiq-cron")

      create_file "config/initializers/sidekiq.rb", <<~RUBY unless File.exist?("config/initializers/sidekiq.rb")
        require "sidekiq"
        Sidekiq.configure_server do |config|
          config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
        end

        Sidekiq.configure_client do |config|
          config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
        end
      RUBY

      create_file "config/sidekiq.yml", <<~YAML unless File.exist?("config/sidekiq.yml")
        :concurrency: 5
        :queues:
          - default
          - mailers
      YAML

      safe_insert_into_file(
        "config/routes.rb",
        "Rails.application.routes.draw do\n",
        <<~RUBY
          require "sidekiq/web"
          mount Sidekiq::Web => "/sidekiq" if Rails.env.development?
        RUBY
      )

      say ""
      say_status "done", "✅ Sidekiq setup complete!", :green
      say "- Run `bundle install`", :blue
      say "- Start Redis: `redis-server`", :blue
      say "- Start Sidekiq: `bundle exec sidekiq -C config/sidekiq.yml`", :blue
    end

    def remove_sidekiq_setup_if_last_worker
      if behavior == :revoke
        # Check for remaining workers
        workers = Dir.glob("app/workers/*_worker.rb")
        if workers.empty?
          # Remove Sidekiq route
          gsub_file "config/routes.rb", /.*mount Sidekiq::Web.*\n/, ""
          # Optionally remove Sidekiq initializer or other setup
          remove_file "config/initializers/sidekiq.rb" if File.exist?("config/initializers/sidekiq.rb")
        end
      end
    end
  end
end
