# lib/generators/shared/sidekiq_support.rb
module Shared
  module SidekiqSupport
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
      safe_add_gem("sidekiq")
      safe_add_gem("sidekiq-cron")

      create_sidekiq_initializer
      create_sidekiq_config
      add_sidekiq_admin_routes

      say ""
      say_status "done", "✅ Sidekiq setup complete!", :green
      say "- Run `bundle install`", :blue
      say "- Start Redis: `redis-server`", :blue
      say "- Start Sidekiq: `bundle exec sidekiq -C config/sidekiq.yml`", :blue
    end

    def create_sidekiq_initializer
      create_file "config/initializers/sidekiq.rb", <<~RUBY
        require "sidekiq"

        app_namespace =
          if Rails.application.class.respond_to?(:module_parent_name)
            Rails.application.class.module_parent_name.underscore + "_sidekiq"
          else
            Rails.application.class.module_parent.name.underscore + "_sidekiq"
          end

        Sidekiq.configure_server do |config|
          config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"), namespace: app_namespace }
        end

        Sidekiq.configure_client do |config|
          config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"), namespace: app_namespace }
        end
      RUBY
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
      safe_insert_into_file(
        "config/routes.rb",
        needle: /^end/,
        content: <<~RUBY,
          require "sidekiq/web"
          require "sidekiq/cron/web"

          authenticate :user, lambda { |u| u.as_admin? } do
            mount Sidekiq::Web => "/sidekiq"
          end
        RUBY
        position: :before
      )
    end

    def remove_sidekiq_setup_if_last_worker
      workers = Dir.glob("app/workers/*_worker.rb")
      return unless workers.empty?

      gsub_file "config/routes.rb", /.*mount Sidekiq::Web.*\n/, ""
      remove_file "config/initializers/sidekiq.rb" if File.exist?("config/initializers/sidekiq.rb")
    end
  end
end
