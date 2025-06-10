gem 'rolify'
gem 'cancancan'

after_bundle do
  generate 'rolify', 'Role', 'User'
  generate 'cancan:ability'
end
