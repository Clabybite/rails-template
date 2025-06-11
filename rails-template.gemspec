# rails-template.gemspec

Gem::Specification.new do |spec|
  spec.name          = "rails-template"
  spec.version       = "0.1.0"
  spec.authors       = ["Clarence"]
  spec.email         = ["clabybite@gmail.com"]

  spec.summary       = "Custom Rails application template and generators"
  spec.description   = "A Rails starter kit with reusable generators for features like breadcrumbs, current_user, layout, etc."
  spec.homepage      = "https://github.com/Clabybite/rails-template"
  spec.license       = "MIT"

  # Files to include in the gem
  spec.files = Dir[
    "lib/**/*.rb",
    "lib/**/*.erb",
    "lib/**/*.yml",
    "templates/**/*",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  # Runtime dependencies (if any — e.g., template helper gems)
  spec.add_dependency "rails", ">= 6.1"
end
