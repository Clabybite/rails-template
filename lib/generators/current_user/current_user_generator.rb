class CurrentUserGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_current_model
    copy_file "current.rb", "app/models/current.rb"
  end

  def ensure_before_action
    path = "app/controllers/application_controller.rb"
    hook_line = "class ApplicationController < ActionController::Base"

    unless File.read(path).include?("before_action :set_current_user")
      insert_into_file path, "  before_action :set_current_user\n", after: "#{hook_line}\n"
      say_status :added, "✅ Added before_action :set_current_user", :green
    else
      say_status :skipped, "⚠️ before_action already exists", :yellow
    end
  end

  def inject_set_current_user
    path = "app/controllers/application_controller.rb"

    if File.read(path).include?("def set_current_user")
      say_status :skipped, "⚠️ set_current_user method already exists", :yellow
      return
    end

    inject_into_class path, "ApplicationController", <<~RUBY

      private

      def set_current_user
        Current.user = current_user if user_signed_in?
      end
    RUBY

    say_status :added, "✅ Injected set_current_user method", :green
  end
end
