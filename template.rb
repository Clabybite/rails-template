# encoding: utf-8
# Detect if running in CI
ci_mode = ENV["CI"] == "true"

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end
def safe_gem(name, *args)
  gemfile = File.read("Gemfile") rescue ""
  normalized_gemfile = gemfile.gsub(/['"]/, "'") # Normalize double quotes to single quotes
  gem(name, *args) unless normalized_gemfile.include?("gem \"#{name}\"")
end
def prompt_or_default(message, default, echo: true)
  return default if ENV["CI"] == "true"
  value = ask("#{message} [default: #{default}]:", echo: echo).presence
  say value ? "You entered: #{value}" : "Using default: #{default}", :green
  value || default
end

# Prompt for app name
@app_name = prompt_or_default("📦 What is your app name?", "my_app")

# Prompt for superuser details
@superuser_email = prompt_or_default("📧 Superuser email", "admin@example.com")
@superuser_password = prompt_or_default("🔐 Superuser password", "password", echo: true)

# Prompt for DB credentials
@db_user = prompt_or_default("🧑‍💻 DB username", "root")
@db_pass = prompt_or_default("🔐 DB password (leave blank for none):","", echo: true)

apply "templates/database.rb"

# rails-template/
# ├── template.rb               # main entry point
# ├── templates/
# │   ├── devise.rb
# │   ├── roles.rb
# │   ├── layout.rb
# │   ├── layout_parts/
# │   │   ├── application_layout.rb
# │   │   ├── header.rb
# │   │   ├── sidebar.rb
# │   │   └── footer.rb
# │   └── seed_superuser.rb
# ├── README.md
# ├── .gitignore

say "🛠 Setting up Rails app with Devise, Rolify, AdminLTE...", :green


# Add main gems
safe_gem 'importmap-rails'
safe_gem 'turbo-rails'
safe_gem 'stimulus-rails'
gem 'jquery-rails'
gem 'sassc-rails'
gem 'bootstrap'
gem 'kaminari'
gem 'shrine'
gem 'acts-as-taggable-on'
gem 'friendly_id'
gem 'validates_timeliness'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'fugit'
gem 'marcel'
gem 'devise'
gem 'devise_invitable'
gem 'rolify'
gem 'cancancan'


gem_group :development, :test do
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'byebug'
end

gem_group :development do
  gem 'letter_opener'
  gem 'bullet'
  safe_gem 'brakeman', require: false
  safe_gem 'web-console'
end

after_bundle do

  
apply "templates/devise.rb"
apply "templates/roles.rb"

  # Create & migrate DB
  rails_command "db:create"
  rails_command "db:migrate"

apply "templates/seed_superuser.rb"

  # Install JS tools
  rails_command "importmap:install"
  rails_command "turbo:install"
  rails_command "stimulus:install"

 # Add Stimulus controller
  run "mkdir -p app/javascript/controllers"
  create_file "app/javascript/controllers/hello_controller.js", <<~JS
    import { Controller } from "@hotwired/stimulus"
    export default class extends Controller {
      connect() {
        console.log("Hello from Stimulus!")
      }
    }
  JS
  rails_command "stimulus:manifest"
  rails_command "stimulus:controllers"

  
  # Ensure Sprockets manifest exists
  create_file "app/assets/config/manifest.js", <<~JS
    //= link_tree ../images
    //= link_tree ../builds
    //= link_directory ../stylesheets .css
  JS

  apply "templates/layout.rb"  # Loads AdminLTE layout with modular partials


  if !ci_mode
    git :init
    git add: "."
    git commit: "-m 'Initial Rails template setup'"
  end


  say "✅ Setup complete!", :green
end