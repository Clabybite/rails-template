module WithBreadcrumbs
  extend ActiveSupport::Concern

  included do
    helper_method :breadcrumbs
    before_action :set_breadcrumbs
  end

  def breadcrumbs
    @breadcrumbs ||= []
  end

  def add_breadcrumb(name, path = nil, active = false)
    breadcrumbs << Breadcrumb.new(name, path, active)
  end

  def set_breadcrumbs(title = nil, link = nil, active = false)
    add_breadcrumb("Home", "/")
    add_breadcrumb(title, link, active) if title
  end
end
