gem 'devise'
gem 'devise_invitable'

after_bundle do
  generate 'devise:install'
  generate 'devise_invitable:install'
  generate 'devise', 'User'
end
