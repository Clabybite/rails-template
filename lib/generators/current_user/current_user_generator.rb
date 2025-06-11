# lib/generators/current_user/current_user_generator.rb
class CurrentUserGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_current_model
    copy_file "current.rb", "app/models/current.rb"
  end

  def ensure_before_action
    file_path = "app/controllers/application_controller.rb"
    hook_line = "class ApplicationController < ActionController::Base"

    unless File.read(file_path).include?("before_action :set_current_user")
      insert_into_file file_path, "  before_action :set_current_user\n", after: "#{hook_line}\n"
      say_status :added, "Inserted `before_action :set_current_user`", :green
    else
      say_status :skipped, "`before_action :set_current_user` already exists", :yellow
    end
  end

  def inject_set_current_user
    file_path = "app/controllers/application_controller.rb"
    content = File.read(file_path)

    if content.include?("def set_current_user")
      say_status :skipped, "`set_current_user` method already exists", :yellow
      return
    end

    if content.include?("private")
      inject_setter_after_private(file_path)
    else
      append_to_file file_path, <<~RUBY

        private

        def set_current_user
          Current.user = current_user if user_signed_in?
        end
      RUBY
      say_status :added, "`set_current_user` method added at end", :green
    end
  end

  private

  def inject_setter_after_private(file_path)
    gsub_file file_path, /(^\s*private\s*$)/ do |match|
      <<~RUBY.chomp
        #{match}

        def set_current_user
          Current.user = current_user if user_signed_in?
        end
      RUBY
    end
    say_status :added, "`set_current_user` method injected after private", :green
  end
end
