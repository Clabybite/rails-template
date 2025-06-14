require "rails/generators"

module Generators
  module SidekiqWorker
    class SidekiqWorkerGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_worker_file
        template "worker.rb.tt", File.join("app/workers", class_path, "#{file_name}.rb")
      end

      def create_test_file
        template "worker_test.rb.tt", File.join("test/workers", class_path, "#{file_name}_test.rb")
      end
    end
  end
end