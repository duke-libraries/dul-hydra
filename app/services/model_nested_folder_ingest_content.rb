class ModelNestedFolderIngestContent

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def call
    case
      when node.is_root?
        'Collection'
      when node.is_leaf?
        'Component'
    end
  end

end
