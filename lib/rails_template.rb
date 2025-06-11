# lib/rails_template.rb
require "rails"

# Load generators
Dir[File.join(__dir__, "generators", "**", "*_generator.rb")].each { |file| require file }
