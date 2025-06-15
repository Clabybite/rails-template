# lib/rails_template/railtie.rb
require "rails/railtie"

module RailsTemplate
  class Railtie < Rails::Railtie
    # This block executes when the Rails application boots up.
    # Rails automatically looks for generators within a gem's `lib/generators` directory
    # once the gem's railtie is loaded.
    # You generally don't need explicit `generators do ...` block unless doing something custom.

    # If you have specific setup that needs to run *after* Rails is fully loaded
    # but before initializers, you can use `config.after_initialize`.
    # For generators, Rails' built-in discovery mechanism is usually enough
    # as long as the files are in the correct `lib/generators/your_gem_name/` structure.
  end
end