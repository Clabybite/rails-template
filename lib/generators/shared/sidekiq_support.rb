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
        # config/initializers/sidekiq.rb
        require 'sidekiq'
        require 'redis'
        require 'zlib'

        APP_ID = "#{Rails.application.class.module_parent_name rescue 'default_app'}:#{Rails.env}"
        REDIS_HOST = ENV.fetch("REDIS_HOST", "localhost")
        REDIS_PORT = ENV.fetch("REDIS_PORT", "6379")
        MAX_DB = 15

        def find_or_assign_redis_db
            (0..MAX_DB).each do |db|
                redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT, db: db)
                marker = redis.get("sidekiq_app_id")

                return db if marker == APP_ID

                if marker.nil?
                    redis.set("sidekiq_app_id", APP_ID)
                    Rails.logger.info "[Sidekiq] Assigned Redis DB ##{db} to #{APP_ID}"
                    return db
                end
            end

            raise "No free Redis DB available (0..#{MAX_DB} already taken)"
        end

        redis_db = ENV["REDIS_DB"] || find_or_assign_redis_db
        redis_url = "redis://#{REDIS_HOST}:#{REDIS_PORT}/#{redis_db}"

        Sidekiq.configure_server { |config| config.redis = { url: redis_url } }
        Sidekiq.configure_client { |config| config.redis = { url: redis_url } }

        Rails.logger.info "[Sidekiq] '#{APP_ID}' using Redis DB ##{redis_db}"
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
        content: [
            'require "sidekiq/web"',
            'require "sidekiq/cron/web"',
            <<~RUBY
            authenticate :user, lambda { |u| u.as_admin? } do
                mount Sidekiq::Web => "/sidekiq"
            end
            RUBY
        ],
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
