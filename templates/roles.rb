gem 'rolify'
gem 'cancancan'

after_bundle do
  # Remove existing rolify migration if present
  # Dir.glob("db/migrate/*rolify*.rb").each { |f| remove_file f }

  # Generate rolify and cancancan
  generate "rolify", "Role", "User"
  generate "cancan:ability"

  # rails_command "db:migrate"
end