# encoding: utf-8

after_bundle do
  append_to_file "db/seeds.rb", <<~RUBY
    puts "🌱 Seeding superuser..."

    user = User.find_or_create_by!(email: "#{@superuser_email}") do |u|
      u.password = "#{@superuser_password}"
      u.password_confirmation = "#{@superuser_password}"
    end

    user.add_role :superuser if user.roles.blank?
    user.save!
    puts "✅ Superuser created: \#{user.email}"
  RUBY

  rails_command "db:seed"
end
