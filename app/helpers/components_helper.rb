module ComponentsHelper

  def collection
    @collection ||= parent.parent
  end

end
