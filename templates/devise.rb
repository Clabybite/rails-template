after_bundle do
  generate 'devise:install'
  generate 'devise_invitable:install'
  file = Dir.glob("db/migrate/*add_devise_to_users*.rb").first
remove_file file if file

  unless File.exist?("app/models/user.rb") || Dir.glob("db/migrate/*devise_create_users*.rb").any?
    generate 'devise', 'User'
  end
  # rails_command 'db:migrate'
  generate 'devise:views'
end
