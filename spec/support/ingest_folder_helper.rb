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
    dss[obj.identifier] = {}
    rels[obj.identifier] = {}
    obj.batch_object_datastreams.each { |ds| dss[obj.identifier][ds.name] = ds }
    obj.batch_object_relationships.each { |rel| rels[obj.identifier][rel.name] = rel }
  end
  [ objects, dss, rels ]
end