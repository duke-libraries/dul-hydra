class BuildBatchFromFolderIngest

  attr_reader :user, :filesystem, :content_modeler, :metadata_provider, :checksum_provider, :batch_name, :batch_description
  attr_accessor :batch, :collection_rec_id

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
    batch.update_attributes(status: Ddr::Batch::Batch::STATUS_READY)
    batch    
  end

  private

  def create_batch
    Ddr::Batch::Batch.create(user: user, name: batch_name, description: batch_description)
  end

  def traverse_filesystem
    filesystem.each do |node|
      obj = create_object(node)
    end
  end

  def create_object(node)
    object_model = content_modeler.new(node).call
    # pid = assign_pid(node) if ['Collection', 'Item'].include?(object_model)
    # self.collection_pid = pid if object_model == 'Collection'
    batch_object = Ddr::Batch::IngestBatchObject.create(batch: batch, model: object_model)
    node.content ||= {}
    node.content[:rec_id] = batch_object.id
    self.collection_rec_id = batch_object.id if object_model == 'Collection'
    add_relationships(batch_object, node.parent)
    add_metadata(batch_object, node)
    add_content_datastream(batch_object, node) if object_model == 'Component'
  end

  # def assign_pid(node)
  #   node.content ||= {}
  #   node.content[:pid] = ActiveFedora::Base.connection_for_pid('0').mint
  # end
  #
  def add_relationships(batch_object, parent_node)
    # batch_object.batch_object_relationships <<
    #       create_relationship(Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY, collection_rec_id)
    create_relationship(batch_object, Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY, collection_rec_id)
    case batch_object.model
    when 'Item'
      # batch_object.batch_object_relationships <<
      create_relationship(batch_object, Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_PARENT, parent_node.content[:rec_id])
    when 'Component'
      # batch_object.batch_object_relationships <<
      create_relationship(batch_object, Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_PARENT, parent_node.content[:rec_id])
    end
  end

  def add_metadata(batch_object, node)
    locator = Filesystem.node_locator(node)
    metadata_provider.metadata(locator).each do |key, value|
      Array(value).each do |v|
        Ddr::Batch::BatchObjectAttribute.create(
              batch_object: batch_object,
              datastream: Ddr::Datastreams::DESC_METADATA,
              name: key,
              operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
              value: v,
              value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
        )
      end
    end
  end

  def add_content_datastream(batch_object, node)
    full_filepath = Filesystem.path_to_node(node)
    rel_filepath = Filesystem.path_to_node(node, 'relative')
    ds = Ddr::Batch::BatchObjectDatastream.create(
      name: Ddr::Datastreams::CONTENT,
      operation: Ddr::Batch::BatchObjectDatastream::OPERATION_ADD,
      payload: full_filepath,
      payload_type: Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME,
      checksum: checksum_provider.checksum(rel_filepath),
      checksum_type: Ddr::Datastreams::CHECKSUM_TYPE_SHA256
    )
    batch_object.batch_object_datastreams << ds
  end

  def create_relationship(batch_object, relationship_name, relationship_target_rec_id)
    Ddr::Batch::BatchObjectRelationship.create(
        batch_object: batch_object,
        name: relationship_name,
        operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD,
        object: relationship_target_rec_id,
        object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REC_ID
    )
  end

end