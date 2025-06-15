require "rails/generators"
require_relative "../shared/helpers"
class ScheduledJobGenerator < Rails::Generators::Base
    include GeneratorHelpers 
    source_root File.expand_path("templates", __dir__)

    def create_views
      directory "shared", "app/views/shared"
    end
end