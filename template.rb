def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end
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

# template.rb
say "🛠 Setting up Rails app with Devise, Rolify, AdminLTE...", :green

# Add main gems
gem 'devise'
gem 'devise_invitable'
gem 'rolify'
gem 'cancancan'
gem 'stimulus-rails'
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
  gem 'brakeman', require: false
  gem 'web-console'
end

apply "templates/devise.rb"
apply "templates/roles.rb"
apply "templates/layout.rb"  # Loads AdminLTE layout with modular partials
apply "templates/seed_superuser.rb"

after_bundle do
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
    # Git
  git :init
  git add: "."
  git commit: "-m 'Initial Rails template setup'"
end