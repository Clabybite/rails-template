superuser_email = ask("📧 Superuser email [default: admin@example.com]:").presence || "admin@example.com"
superuser_password = ask("🔐 Superuser password [default: password]:", echo: false).presence || "password"

after_bundle do
  append_to_file "db/seeds.rb", <<~RUBY
    puts "🌱 Seeding superuser..."

    user = User.find_or_create_by!(email: "#{superuser_email}") do |u|
      u.password = "#{superuser_password}"
      u.password_confirmation = "#{superuser_password}"
    end

    user.add_role :superuser
    puts "✅ Superuser created: \#{user.email}"
  RUBY

  rails_command "db:seed"
end
