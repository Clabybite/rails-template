require "rails/generators"
require_relative "shared/helpers"
class ScheduledJobGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def generate_model_and_migration
    generate("model", "ScheduledJob name:string job_class:string cron:string queue:string active:boolean")
  end

  def overwrite_model
    template "scheduled_job.rb", "app/models/scheduled_job.rb"
  end

  def create_controller
    template "scheduled_jobs_controller.rb", "app/controllers/admin/scheduled_jobs_controller.rb"
  end

  def create_views
    directory "scheduled_jobs", "app/views/admin/scheduled_jobs"
  end

  def patch_routes
    safe_insert_into_file(
        "config/routes.rb",
        needle: /^end/,
        content: <<~RUBY,
            mount Sidekiq::Web => "/sidekiq" if Rails.env.development?
        RUBY
        position: :before
    )
  end

  private

  def root_path(path)
    File.expand_path(path, destination_root)
  end

end
