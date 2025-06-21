# lib/generators/shared/sidekiq_support.rb
module Shared
  module SidekiqSupport
    def self.included(base)
      base.class_eval do
        # Add shared template path to the source paths
        def self.source_paths
          super + [File.expand_path("templates", __dir__)]
        end
      end
    end
    def maybe_setup_sidekiq
        return if behavior == :revoke  # Do nothing if destroying
        if File.exist?("config/initializers/sidekiq.rb")
            answer = ask("⚠️ Sidekiq already seems to be installed. Do you want to skip setup? (yes/no) [yes]:", :yellow)
            return if answer.blank? || answer.downcase.start_with?("y")
        end

        setup_sidekiq
    end

    def setup_sidekiq
      return if behavior == :revoke  # Do nothing if destroying
      add_redis_dependency
      safe_add_gem('sidekiq')
      safe_add_gem('sidekiq-cron')

      create_sidekiq_initializer
      create_sidekiq_config
      setup_redis_instance
      add_sidekiq_admin_routes

      say ""
      say_status "done", "✅ Sidekiq setup complete!", :green
      say "- Run `bundle install`", :blue
      say "- Start Redis: `redis-server`", :blue
      say "- Start Sidekiq: `bundle exec sidekiq -C config/sidekiq.yml`", :blue
    end

    def create_sidekiq_initializer
      template "sidekiq_initializer.rb.tt", "config/initializers/sidekiq.rb"
    end

    def create_sidekiq_config
      create_file "config/sidekiq.yml", <<~YAML
        :concurrency: 5
        :queues:
          - default
          - mailers
      YAML
    end

    def add_sidekiq_admin_routes
      safe_add_route(
        needle: /^end/,
        content: [
            "require 'sidekiq/web'",
            "require 'sidekiq/cron/web'",
            <<~RUBY
            authenticate :user, lambda { |u| u.as_admin? } do
                mount Sidekiq::Web => '/sidekiq'
            end
            RUBY
        ],
        position: :before
      )
    end

    def setup_redis_instance
      empty_directory "redis/data"

      template "start.sh", "redis/start.sh"

      chmod "redis/start.sh", 0755
    end

    def remove_sidekiq_setup_if_last_worker
      workers = Dir.glob("app/workers/*_worker.rb")
      jobs = Dir.glob("app/jobs/*_job.rb")

      return unless workers.empty? && jobs.empty? # Exit early unless both are empty


      gsub_file "config/routes.rb", /.*mount Sidekiq::Web.*\n/, ""
      remove_file "config/initializers/sidekiq.rb" if File.exist?("config/initializers/sidekiq.rb")
    end

    def add_redis_dependency
      safe_add_gem('redis')
      Bundler.with_unbundled_env { run "bundle install" }
    end
    
  end
end
