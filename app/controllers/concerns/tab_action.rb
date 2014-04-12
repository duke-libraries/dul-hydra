class TabAction

  attr_reader :id, :href, :guard

  def initialize(id, href, guard=true)
    @id = id
    @href = href
    @guard = guard
  end

end
