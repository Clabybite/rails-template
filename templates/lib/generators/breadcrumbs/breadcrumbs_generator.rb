class BreadcrumbsGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_concern
    copy_file "with_breadcrumbs.rb", "app/controllers/concerns/with_breadcrumbs.rb"
  end

  def inject_into_app_controller
    inject_into_class "app/controllers/application_controller.rb", "ApplicationController", "  include WithBreadcrumbs\n"
  end

  def copy_model
    copy_file "breadcrumb.rb", "app/models/breadcrumb.rb"
  end

  def copy_view
    template "breadcrumbs.html.erb", "app/views/shared/_breadcrumbs.html.erb"
  end
end
