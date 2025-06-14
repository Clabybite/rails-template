# test/generators/sidekiq_worker_generator_test.rb
require "test_helper"

class SidekiqWorkerGeneratorTest < Rails::Generators::TestCase
  tests SidekiqWorker::SidekiqWorkerGenerator
  destination File.expand_path("../../tmp", __FILE__)
  setup :prepare_destination
    def prepare_destination
        super  # Always call super to ensure cleanup happens
        File.write(File.join(destination_root, "Gemfile"), "")
        FileUtils.mkdir_p(File.join(destination_root, "config"))
  File.write(File.join(destination_root, "config/routes.rb"), "Rails.application.routes.draw do\nend\n")
    end


  def test_creates_worker_and_test_file
    run_generator ["MyJob"]

    assert_file "app/workers/my_job.rb", /class MyJob/
    assert_file "test/workers/my_job_test.rb", /MyJobTest/
  end

  def test_adds_sidekiq_gem
    run_generator ["MyJob"]
    gemfile = File.read(File.join(destination_root, "Gemfile"))
    assert_match /gem "sidekiq"/, gemfile
  end
end
