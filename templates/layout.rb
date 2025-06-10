after_bundle do
  say "⬇️ Installing AdminLTE layout...", :green

  # Download AdminLTE assets
  run "mkdir -p vendor/assets/adminlte"
  run "curl -sL https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/css/adminlte.min.css -o vendor/assets/adminlte/adminlte.min.css"
  run "curl -sL https://cdn.jsdelivr.net/npm/admin-lte@3.2/dist/js/adminlte.min.js -o vendor/assets/adminlte/adminlte.min.js"

  # Link assets
  append_to_file "app/assets/stylesheets/application.css", " *= require adminlte/adminlte.min\n"
  append_to_file "app/assets/javascripts/application.js", "//= require adminlte/adminlte.min\n"

  # Home controller and root route
  generate "controller", "home", "index", "--skip-assets", "--skip-helper"
  route "root to: 'home#index'"

  # Layout and partials
  apply File.expand_path("layout_parts/application_layout.rb", __dir__)
    apply File.expand_path("layout_parts/header.rb", __dir__)
    apply File.expand_path("layout_parts/sidebar.rb", __dir__)
    apply File.expand_path("layout_parts/footer.rb", __dir__)

end
