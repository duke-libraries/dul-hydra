class ModelStandardIngestContent

  attr_reader :node, :targets_name

  def initialize(node, targets_name=nil)
    @node = node
    @targets_name = targets_name
  end

  def call
    raise DulHydra::BatchError, "Node #{node.name} too deep for standard ingest" if node.node_depth > 2
    raise DulHydra::BatchError, "Deepest permitted node #{node.name} has children" if node.node_depth == 2 && node.has_children?
    case
    when node.is_root?
      'Collection'
      when node.node_depth == 1
        case
          when node.name == targets_name
            nil
          else
            'Item'
        end
      when node.node_depth == 2
        case
          when node.parent.name == targets_name
            'Target'
          else
            'Component'
        end
    end
  end

end
