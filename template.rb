# encoding: utf-8
# Detect if running in CI
ci_mode = ENV["CI"] == "true"

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end
def safe_gem(name, *args)
  gemfile = File.read("Gemfile") rescue ""
  gem(name, *args) unless gemfile.include?(name)
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

# Generate config/database.yml manually
create_file "config/database.yml", <<~YML
  default: &default
    adapter: mysql2
    encoding: utf8mb4
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    username: #{@db_user}
    password: #{@db_pass}
    host: localhost

  development:
    <<: *default
    database: #{@app_name}_development

  test:
    <<: *default
    database: #{@app_name}_test

  production:
    <<: *default
    database: #{@app_name}_production
    username: #{@db_user}
    password: #{@db_pass}
YML

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
  run "bundle show kamal > kamal_origin.txt"
  say "Kamal is brought in by: #{File.read('kamal_origin.txt')}", :red

  
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


  # Git
  git :init
  git add: "."
  git commit: "-m 'Initial Rails template setup'"

  say "✅ Setup complete!", :green
end