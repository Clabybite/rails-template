# lib/rails_template.rb
# frozen_string_literal: true # Good practice to include this

require "rails_template/version" # This should work because $:.unshift for lib is in test_helper.rb

# Only load the Railtie if Rails is defined.
require "rails_template/railtie" if defined?(Rails)

module RailsTemplate
  # *** CRITICAL: DEFINE THE 'Generators' MODULE HERE ***
  # This ensures `RailsTemplate::Generators` is available immediately
  # when `lib/rails_template.rb` is required.
  module Generators
    # This module can be empty, or contain shared constants/methods
    # that are not dependent on Rails::Generators::Base (as Base is defined later
    # when individual generator files or a generator_base.rb are loaded).
  end
  # *******************************************************

  # Your gem's configuration or core logic
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :some_setting
    def initialize
      @some_setting = "default_value"
    end
  end

  # IMPORTANT: Do NOT put any `Dir.glob` or direct `require` statements for your specific
  # generator files (like `sidekiq_worker_generator.rb`, `breadcrumbs_generator.rb`) here.
  # Rails' autoloader (via your Railtie) or your test_helper.rb's explicit requires
  # will handle those at the correct time.
end