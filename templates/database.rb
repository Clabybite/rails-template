# Generate config/database.yml manually
if ENV["DB"] == "mysql"
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
else
  create_file "config/database.yml", <<~YML
    default: &default
      adapter: sqlite3
      pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
      timeout: 5000

    development:
      <<: *default
      database: db/#{@app_name}_development.sqlite3

    test:
      <<: *default
      database: db/#{@app_name}_test.sqlite3

    production:
      <<: *default
      database: db/#{@app_name}_production.sqlite3
  YML
end