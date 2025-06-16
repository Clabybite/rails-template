# lib/generators/sidekiq_worker/sidekiq_worker_generator.rb
require_relative "../shared/helpers"
module SidekiqWorker
  class SidekiqWorkerGenerator < Rails::Generators::NamedBase
    include GeneratorHelpers
    include Shared::SidekiqSupport
    source_root File.expand_path("templates", __dir__)
    desc "Generates a Sidekiq worker and its test"

    def create_worker_file
      template "worker.rb.tt", File.join("app/workers", class_path, "#{file_name}.rb")
      if behavior == :invoke
        setup_sidekiq_if_needed
      elsif behavior == :revoke
        remove_sidekiq_setup_if_last_worker
      end
    end

    def create_test_file
      template "worker_test.rb.tt", File.join("test/workers", class_path, "#{file_name}_test.rb")
    end

    def setup_sidekiq_if_needed
      maybe_setup_sidekiq
    end
  end
end
