class BuildBatchFromDatastreamUpload

  attr_reader :batch_user, :checksum_provider, :collection, :filesystem, :batch_name, :batch_description,
              :datastream_name
  attr_accessor :batch

  def initialize(batch_description: nil, batch_name: 'Datastream Uploads', batch_user:, checksum_file_path: nil,
                 collection:, datastream_name:, filesystem:)
    @batch_description = batch_description
    @batch_name = batch_name
    @batch_user = batch_user
    @checksum_provider = IngestChecksum.new(checksum_file_path) if checksum_file_path.present?
    @collection = collection
    @datastream_name = datastream_name
    @filesystem = filesystem
  end

  def call
    @batch = create_batch
    traverse_filesystem
    batch.update_attributes(status: Ddr::Batch::Batch::STATUS_READY)
    batch
  end

  private

  def create_batch
    Ddr::Batch::Batch.create(user: batch_user, name: batch_name, description: batch_description)
  end

  def traverse_filesystem
    filesystem.tree.each_leaf do |leaf|
      file_path = Filesystem.path_to_node(leaf)
      builder_args = { batch: batch, datastream_name: datastream_name, file_path: file_path,
                       repo_id: find_matching_component(collection, file_path) }
      builder_args.merge!(checksum: checksum_provider.checksum(file_path)) if checksum_provider.present?
      BuildBatchObjectFromDatastreamUpload.new(builder_args).call
    end
  end

  def find_matching_component(collection, file_path)
    basename = File.basename(file_path, '.*')
    ids = find_matching_component_ids(collection, basename)
    case
      when ids.count == 0
        raise DulHydra::Error, "Unable to find matching component '#{basename}' for #{file_path}"
      when ids.count > 1
        raise DulHydra::Error, "Multiple components found matching for '#{basename}' for #{file_path}"
      else
        ids.first
    end
  end

  def find_matching_component_ids(collection, basename)
    ids = matching_component_query_by_local_id(collection, basename).ids
    if ids.count == 0
      ids = matching_component_query_by_filename(collection, basename).ids
    end
    ids
  end

  def matching_component_query_by_local_id(collection, local_id)
    Ddr::Index::Query.new do
      model 'Component'
      is_governed_by collection
      where local_id: local_id
      fields 'id'
    end
  end

  def matching_component_query_by_filename(collection, filename)
    Ddr::Index::Query.new do
      model 'Component'
      is_governed_by collection
      raw "#{Ddr::Index::Fields::ORIGINAL_FILENAME}:/#{filename}.*/"
      fields 'id'
    end
  end
end
