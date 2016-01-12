require 'spec_helper'

def test_mets_folder_config
  config = <<-EOS
    :scanner:
        :exclude:
            - .DS_Store
            - Thumbs.db
    :display_format:
        slideshow: multi_image
  EOS
end

def filesystem_mets_folder
  root_node = Tree::TreeNode.new('/test/directory')
  fileA_node = Tree::TreeNode.new('fileA.xml')
  root_node << fileA_node
  fileB_node = Tree::TreeNode.new('fileB.xml')
  root_node << fileB_node
  root_node
end

def filesystem_non_mets_folder
  root_node = Tree::TreeNode.new('/test/directory')
  fileA_node = Tree::TreeNode.new('fileA.xml')
  root_node << fileA_node
  fileB_node = Tree::TreeNode.new('fileB.txt')
  root_node << fileB_node
  root_node
end

