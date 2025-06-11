class Breadcrumb
  attr_reader :name, :path, :active

  def initialize(name, path = nil, active = false)
    @name = name
    @path = path
    @active = active
  end
end
