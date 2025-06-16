require "rails/generators"
require_relative "../shared/helpers"
require_relative "../shared/sidekiq_support"
class ScheduledJobGenerator < Rails::Generators::Base
    include GeneratorHelpers 
    include Shared::SidekiqSupport
  source_root File.expand_path("templates", __dir__)

  def generate_model_and_migration
    generate("model", "ScheduledJob name:string job_class:string cron:string queue:string active:boolean")
  end

  def overwrite_model
    template "scheduled_job.rb", "app/models/scheduled_job.rb"
  end

  def create_base_controller
    template "base_controller.rb", "app/controllers/admin/base_controller.rb"
  end
  def create_controller
    template "scheduled_jobs_controller.rb", "app/controllers/admin/scheduled_jobs_controller.rb"
  end

  def create_views
    directory "scheduled_jobs", "app/views/admin/scheduled_jobs"
  end

  def patch_routes
    safe_namespace_route("scheduled_jobs", namespace: :admin)
  end

  def setup_sidekiq_if_needed
    maybe_setup_sidekiq
  end

  private

  def root_path(path)
    File.expand_path(path, destination_root)
  end

end
