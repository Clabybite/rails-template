# test/test_helper.rb
require "minitest/autorun"
require "rails"
require "rails/generators"
require "rails/generators/test_case"

# Load your generator code manually
# test/test_helper.rb
require_relative "../lib/generators/shared/helpers"
require_relative "../lib/generators/sidekiq_worker/sidekiq_worker_generator"
# Global teardown for generator tests
Minitest.after_run do
  tmp = File.expand_path("../tmp", __dir__)
  FileUtils.rm_rf(tmp) if File.directory?(tmp)
end