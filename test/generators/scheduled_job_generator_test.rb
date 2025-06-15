# test/lib/generators/scheduled_job_generator_test.rb
require 'test_helper'
# override_model_generate_for(ScheduledJobGenerator)

class ScheduledJobGeneratorTest < RailsTemplate::Generators::TestCase
  tests ScheduledJobGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination

  def setup
    super
    # Create minimal routes.rb for patching
    FileUtils.mkdir_p File.join(destination_root, "config")
    File.write(File.join(destination_root, "config/routes.rb"), "Rails.application.routes.draw do\nend\n")
  end

  def test_model_and_migration_are_generated
    run_generator
    assert_file "app/models/scheduled_job.rb"
    assert Dir[File.join(destination_root, "db/migrate/*_create_scheduled_jobs.rb")].any?, "Migration was not created"
  end

  def test_controller_is_created
    run_generator
    assert_file "app/controllers/admin/scheduled_jobs_controller.rb"
  end

  def test_views_are_copied
    run_generator
    assert_directory "app/views/admin/scheduled_jobs"
  end

  def test_routes_are_patched
    run_generator
    routes = File.read(File.join(destination_root, "config/routes.rb"))
    assert_match(/mount Sidekiq::Web => "\/sidekiq"/, routes)
  end
end