require 'spec_helper'

def test_ingest_folder_config
  config = <<-EOS
  config:
      file_model: TestChild
      target_model: Target
      target_folder: targets
      checksum_file:
          location: #{checksum_directory}
          type: #{checksum_type}
      file_creators:
          ABC: Alpha Bravo Charlie
  files:
      included_extensions:
          - .mp4
          - .pdf
          - .tif
          - .tiff
          - .wav
      mount_points:
          #{mount_point_name}: #{mount_point_path}
      permissions:
          #{user.user_key}:
          - #{mount_point_name}/path/
  EOS
end

def populate_comparison_hashes(batch_objects)
  batch_objects.each do |obj|
    objects[obj.identifier] = obj
    atts[obj.identifier] = {}
    dss[obj.identifier] = {}
    rels[obj.identifier] = {}
    obj.batch_object_attributes.each { |att| atts[obj.identifier][att.name] = att }
    obj.batch_object_datastreams.each { |ds| dss[obj.identifier][ds.name] = ds }
    obj.batch_object_relationships.each { |rel| rels[obj.identifier][rel.name] = rel }
  end
  [ objects, atts, dss, rels ]
end

def standard_ingest_configuration
  {
    scanner: {
      exclude: [ '.DS_Store', 'Thumbs.db' ],
      targets: 'dpc_targets'
    },
    metadata: {
      filename: 'ddr-ingest-metadata.txt',
      csv: {
        encoding: 'UTF-8',
        headers: true,
        col_sep: '\t'
      },
      parse: {
        locator_field_count: 1,
        repeating_fields_separator: ';',
        repeatable_fields: [ 'contributor', 'creator', 'date', 'subject', 'type' ]
      }
    }
  }
end

def sample_filesystem
  root_node = Tree::TreeNode.new('/test/directory')
  root_node << Tree::TreeNode.new('movie.mp4', {})
  root_node << Tree::TreeNode.new('file01001.tif', {})
  itemA_node = Tree::TreeNode.new('itemA', {})
  itemA_node << Tree::TreeNode.new('file01.pdf', {})
  itemA_node << Tree::TreeNode.new('track01.wav', {})
  root_node << itemA_node
  itemB_node = Tree::TreeNode.new('itemB', {})
  itemB_node << Tree::TreeNode.new('file02.pdf', {})
  itemB_node << Tree::TreeNode.new('track02.wav', {})
  root_node << itemB_node
  root_node
end

def filesystem_standard_ingest
  root_node = Tree::TreeNode.new('/test/directory')
  itemY_node = Tree::TreeNode.new('[movie.mp4]')
  itemY_node << Tree::TreeNode.new('movie.mp4')
  root_node << itemY_node
  itemZ_node = Tree::TreeNode.new('[file01001.tif]')
  itemZ_node << Tree::TreeNode.new('file01001.tif')
  root_node << itemZ_node
  itemA_node = Tree::TreeNode.new('itemA')
  itemA_node << Tree::TreeNode.new('file01.pdf')
  itemA_node << Tree::TreeNode.new('track01.wav')
  root_node << itemA_node
  itemB_node = Tree::TreeNode.new('itemB')
  itemB_node << Tree::TreeNode.new('file02.pdf')
  itemB_node << Tree::TreeNode.new('track02.wav')
  root_node << itemB_node
  target_node = Tree::TreeNode.new('dpc_targets')
  target_node << Tree::TreeNode.new('T001.tif')
  root_node << target_node
  root_node
end

def filesystem_three_deep
  root_node = Tree::TreeNode.new('/test/directory')
  itemA_node = Tree::TreeNode.new('itemA')
  root_node << itemA_node
  itemB_node = Tree::TreeNode.new('itemB')
  itemB_node << Tree::TreeNode.new('file02.pdf')
  itemB_node << Tree::TreeNode.new('track02.wav')
  itemA_node << itemB_node
  root_node
end
