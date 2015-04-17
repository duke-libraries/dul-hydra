class BuildBatchFromFolderIngest

  attr_reader :user, :filesystem, :content_modeler, :metadata_provider, :checksum_provider, :batch_name, :batch_description
  attr_accessor :batch, :collection_pid

  def initialize(user, filesystem, content_modeler, metadata_provider, checksum_provider, batch_name=nil, batch_description=nil )
    @user = user
    @filesystem = filesystem
    @content_modeler = content_modeler
    @metadata_provider = metadata_provider
    @checksum_provider = checksum_provider    
    @batch_name = batch_name
    @batch_description = batch_description
  end

  def call
    @batch = create_batch
    traverse_filesystem
    batch.update_attributes(status: DulHydra::Batch::Models::Batch::STATUS_READY)
    batch    
  end

  private

  def create_batch
    DulHydra::Batch::Models::Batch.create(user: user, name: batch_name, description: batch_description)
  end

  def traverse_filesystem
    filesystem.each do |node|
      obj = create_object(node)
    end
  end

  def create_object(node)
    object_model = content_modeler.new(node).call
    pid = assign_pid(node) if ['Collection', 'Item'].include?(object_model)
    self.collection_pid = pid if object_model == 'Collection'
    batch_object = DulHydra::Batch::Models::IngestBatchObject.create(batch: batch, model: object_model, pid: pid)
    add_relationships(batch_object, node.parent)
    add_metadata(batch_object, node)
    add_content_datastream(batch_object, node) if object_model == 'Component'
  end

  def assign_pid(node)
    node.content ||= {}
    node.content[:pid] = ActiveFedora::Base.connection_for_pid('0').mint
  end

  def add_relationships(batch_object, parent_node)
    batch_object.batch_object_relationships <<
          create_relationship(DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY, collection_pid)
    case batch_object.model
    when 'Item'
      batch_object.batch_object_relationships <<
            create_relationship(DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT, parent_node.content[:pid])
    when 'Component'
      batch_object.batch_object_relationships <<
            create_relationship(DulHydra::Batch::Models::BatchObjectRelationship::RELATIONSHIP_PARENT, parent_node.content[:pid])
    end
  end

  def add_metadata(batch_object, node)
    locator = Filesystem.node_locator(node)
    metadata_provider.metadata(locator).each do |key, value|
      Array(value).each do |v|
        DulHydra::Batch::Models::BatchObjectAttribute.create(
              batch_object: batch_object,
              datastream: Ddr::Datastreams::DESC_METADATA,
              name: key,
              operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_ADD,
              value: v,
              value_type: DulHydra::Batch::Models::BatchObjectAttribute::VALUE_TYPE_STRING
        )
      end
    end
  end

  def add_content_datastream(batch_object, node)
    full_filepath = Filesystem.path_to_node(node)
    rel_filepath = Filesystem.path_to_node(node, 'relative')
    ds = DulHydra::Batch::Models::BatchObjectDatastream.create(
      name: Ddr::Datastreams::CONTENT,
      operation: DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADD,
      payload: full_filepath,
      payload_type: DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME,
      checksum: checksum_provider.checksum(rel_filepath),
      checksum_type: Ddr::Datastreams::CHECKSUM_TYPE_SHA256
    )
    batch_object.batch_object_datastreams << ds
  end

  def create_relationship(relationship_name, relationship_target_pid)
    DulHydra::Batch::Models::BatchObjectRelationship.create(
        name: relationship_name,
        operation: DulHydra::Batch::Models::BatchObjectRelationship::OPERATION_ADD,
        object: relationship_target_pid,
        object_type: DulHydra::Batch::Models::BatchObjectRelationship::OBJECT_TYPE_PID
    )
  end

end