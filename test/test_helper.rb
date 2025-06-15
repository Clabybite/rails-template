# test/test_helper.rb
# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

# CRITICAL: THIS MUST BE THE FIRST REQUIRE/LOAD PATH MANIPULATION
$:.unshift File.expand_path("../lib", __dir__)

# Define the path to your dummy Rails application
DUMMY_APP_PATH = File.expand_path("../dummy", __FILE__)

# --- Logic to create the dummy app if it doesn't exist or needs rebuilding ---
unless File.directory?(DUMMY_APP_PATH) && File.exist?("#{DUMMY_APP_PATH}/config/environment.rb")
  puts "\n==> Creating dummy Rails application at #{DUMMY_APP_PATH}..."
  puts "DEBUG: Current Dir before 'rails new': #{Dir.pwd}" # DIAGNOSTIC
  system("rails new #{DUMMY_APP_PATH} --skip-active-storage --skip-action-cable --skip-action-mailbox --skip-action-text --skip-sprockets --skip-webpack-install --skip-javascript --skip-turbolinks --skip-git --skip-system-test")
  puts "DEBUG: 'rails new' finished. Exit status: #{$?.exitstatus}" # DIAGNOSTIC

  unless $?.success?
    abort "ERROR: Failed to create dummy Rails application! Check 'rails new' output above." # Exit if rails new failed
  end

  dummy_gemfile = File.join(DUMMY_APP_PATH, 'Gemfile')
  File.open(dummy_gemfile, 'a') do |f|
    f.puts "\ngem 'rails-template', path: '#{File.expand_path('../../../', __FILE__)}'"
  end
  puts "DEBUG: Current Dir before 'bundle install': #{Dir.pwd}" # DIAGNOSTIC
  system("cd #{DUMMY_APP_PATH} && bundle install")
  puts "DEBUG: 'bundle install' finished. Exit status: #{$?.exitstatus}" # DIAGNOSTIC
  unless $?.success?
    abort "ERROR: Failed to bundle install in dummy Rails application! Check 'bundle install' output above." # Exit if bundle install failed
  end
  puts "Dummy Rails application created and bundled."
end
# --- End of dummy app creation logic ---

puts "DEBUG: Current Dir before requiring environment: #{Dir.pwd}" # DIAGNOSTIC
# 1. First, load the dummy app's Rails environment. THIS DEFINES RAILS::GENERATORS.
require File.expand_path("#{DUMMY_APP_PATH}/config/environment.rb", __FILE__)
puts "DEBUG: Dummy Rails environment loaded." # DIAGNOSTIC

# 2. Now, load your gem's main file (`lib/rails_template.rb`).
#    This will load your Railtie, and define `RailsTemplate::Generators`.
require "rails_template" # This uses the $LOAD_PATH.
puts "DEBUG: RailsTemplate gem loaded." # DIAGNOSTIC

# Minitest and Rails Generator Test Case
require "minitest/autorun"
require "rails/generators/test_case"
puts "DEBUG: Minitest and Rails::Generators::TestCase loaded." # DIAGNOSTIC

# Explicitly require your specific generator files for testing.
# VERIFY YOUR ACTUAL FILE STRUCTURE:
require_relative "../lib/generators/sidekiq_worker/sidekiq_worker_generator"
require_relative "../lib/generators/scheduled_job/scheduled_job_generator"
require_relative "../lib/generators/breadcrumbs/breadcrumbs_generator"
puts "DEBUG: All specific generators required." # DIAGNOSTIC


# Global teardown for generator tests
Minitest.after_run do
  tmp = File.expand_path("dummy/tmp", __dir__) # Points to test/dummy/tmp
  FileUtils.rm_rf(tmp) if File.directory?(tmp)
  # FileUtils.rm_rf(DUMMY_APP_PATH) # Uncomment if you want to clean the dummy app entirely on each run
end

# Define a base class for your gem's generator tests.
puts "DEBUG: Defining RailsTemplate::Generators::TestCase..." # DIAGNOSTIC
class RailsTemplate::Generators::TestCase < Rails::Generators::TestCase
  destination File.expand_path("dummy/tmp", __dir__) # This is correct: test/dummy/tmp
  setup :prepare_destination
end
puts "DEBUG: RailsTemplate::Generators::TestCase defined." # DIAGNOSTIC