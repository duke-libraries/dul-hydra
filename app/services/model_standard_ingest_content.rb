class ModelStandardIngestContent

  attr_reader :node, :intermediate_files_name, :targets_name

  def initialize(node, intermediate_files_name=nil, targets_name=nil)
    @node = node
    @intermediate_files_name = intermediate_files_name
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
          when [ intermediate_files_name, targets_name ].include?(node.name)
            nil
          else
            'Item'
        end
      when node.node_depth == 2
        case
          when node.parent.name == intermediate_files_name
            nil
          when node.parent.name == targets_name
            'Target'
          else
            'Component'
        end
    end
  end

end
