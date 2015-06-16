class ModelSimpleIngestContent

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def call
    raise DulHydra::BatchError, "Node #{node.name} too deep for simple ingest" if node.node_depth > 2
    raise DulHydra::BatchError, "Deepest permitted node #{node.name} has children" if node.node_depth == 2 && node.has_children?
    case
    when node.is_root?
      'Collection'
    when node.node_depth == 1
      'Item'
    when node.node_depth == 2
      'Component'
    end
  end

end