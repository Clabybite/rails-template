# lib/generators/sidekiq_worker/sidekiq_worker_generator.rb
require_relative "../shared/helpers"
module SidekiqWorker
  class SidekiqWorkerGenerator < Rails::Generators::NamedBase
    include GeneratorHelpers
    source_root File.expand_path("templates", __dir__)
    desc "Generates a Sidekiq worker and its test"

    def create_worker_file
      setup_sidekiq
      template "worker.rb.tt", File.join("app/workers", class_path, "#{file_name}.rb")
    end

    def create_test_file
      template "worker_test.rb.tt", File.join("test/workers", class_path, "#{file_name}_test.rb")
    end

    def setup_sidekiq
      # Add sidekiq gems
      safe_add_gem("sidekiq")
      safe_add_gem("sidekiq-cron")

      create_file "config/initializers/sidekiq.rb", <<~RUBY unless File.exist?("config/initializers/sidekiq.rb")
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
  end
end
