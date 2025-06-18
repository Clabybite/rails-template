# lib/generators/sidekiq_worker/sidekiq_worker_generator.rb
require 'rails/generators'
require_relative "../shared/helpers"
require_relative "../shared/sidekiq_support"
class SidekiqWorkerGenerator < Rails::Generators::NamedBase
    include GeneratorHelpers
    include Shared::SidekiqSupport
    source_root File.expand_path("templates", __dir__)
    desc "Generates a Sidekiq worker and its test"

    def adjusted_file_name
      file_name.end_with?("_worker") ? file_name : "#{file_name}_worker"
    end

    def adjusted_class_name
      adjusted_file_name.camelize
    end

    def create_worker_file
      template "worker.rb.tt", File.join("app/workers", class_path, "#{adjusted_file_name}.rb")
    end
    def create_test_file
      template "worker_test.rb.tt", File.join("test/workers", class_path, "#{adjusted_file_name}_test.rb")
    end

    def setup_sidekiq_if_needed
      if behavior == :invoke
        maybe_setup_sidekiq
      elsif behavior == :revoke
        remove_sidekiq_setup_if_last_worker
      end
    end
end
