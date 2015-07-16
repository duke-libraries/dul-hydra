class Filesystem

  attr_accessor :tree

  def initialize(filepath='/')
    @tree = Tree::TreeNode.new(filepath)
  end

  def method_missing(sym, *args, &block)
    @tree.send(sym, *args, &block)
  end

  def self.path_to_node(node, type='full')
    if node.is_root?
      type == 'full' ? node.name : nil
    else
      start_idx = type == 'full' ? 0 : 1
      path_nodes = node.parentage.reverse.map(&:name)[start_idx..-1]
      path_nodes.empty? ? node.name : File.join(path_nodes, node.name)
    end
  end

  def self.node_locator(node)
    path_to_node(node, 'relative')
  end

  def file_count
    count = 0
    each_leaf { |leaf| count += 1 }
    count
  end

end