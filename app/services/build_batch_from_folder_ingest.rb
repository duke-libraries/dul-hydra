class BuildBatchFromFolderIngest

  attr_reader :user, :filesystem, :content_modeler, :metadata_provider, :checksum_provider, :admin_set,
              :collection_repo_id, :batch_name, :batch_description
  attr_accessor :batch, :collection_rec_id

  def initialize(user:, filesystem:, content_modeler:, metadata_provider:, checksum_provider:, admin_set: nil,
                 collection_repo_id: nil, batch_name: nil, batch_description: nil)
    @user = user
    @filesystem = filesystem
    @content_modeler = content_modeler
    @metadata_provider = metadata_provider
    @checksum_provider = checksum_provider
    @admin_set = admin_set
    @collection_repo_id = collection_repo_id
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
      node.content ||= {}
      object_model = content_modeler.new(node).call
      if object_model == 'Collection' && collection_repo_id.present?
        node.content[:repo_id] = collection_repo_id
      end
      create_object(node, object_model) unless node.content[:repo_id].present?
    end
  end

  def create_object(node, object_model)
    batch_object = Ddr::Batch::IngestBatchObject.create(batch: batch, model: object_model)
    node.content[:rec_id] = batch_object.id
    self.collection_rec_id = batch_object.id if object_model == 'Collection'
    add_relationships(batch_object, node.parent)
    add_admin_set(batch_object) if admin_set.present? && object_model == 'Collection'
    add_desc_metadata(batch_object, node)
    add_content_datastream(batch_object, node) if object_model == 'Component'
  end

  def add_relationships(batch_object, parent_node)
    collection_id = collection_repo_id || collection_rec_id
    collection_id_type = collection_repo_id ? Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REPO_ID \
                                            : Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REC_ID
    add_admin_policy_relationship(batch_object, collection_id, collection_id_type)
    case batch_object.model
      when 'Item'
        add_parent_relationship(batch_object, collection_id, collection_id_type)
      when 'Component'
        add_parent_relationship(batch_object, parent_node.content[:rec_id],
                                Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_REC_ID)
    end
  end

  def add_admin_policy_relationship(batch_object, collection_id, collection_id_type)
    Ddr::Batch::BatchObjectRelationship.create(
        batch_object: batch_object,
        name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
        operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD,
        object: collection_id,
        object_type: collection_id_type
    )
  end

  def add_parent_relationship(batch_object, parent_id, parent_id_type)
    Ddr::Batch::BatchObjectRelationship.create(
        batch_object: batch_object,
        name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_PARENT,
        operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD,
        object: parent_id,
        object_type: parent_id_type
    )
  end

  def add_admin_set(batch_object)
    Ddr::Batch::BatchObjectAttribute.create(
        batch_object: batch_object,
        datastream: Ddr::Models::Metadata::ADMIN_METADATA,
        name: 'admin_set',
        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
        value: admin_set,
        value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
    )
  end

  def add_desc_metadata(batch_object, node)
    locator = Filesystem.node_locator(node)
    metadata_provider.metadata(locator).each do |key, value|
      Array(value).each do |v|
        Ddr::Batch::BatchObjectAttribute.create(
            batch_object: batch_object,
            datastream: Ddr::Models::Metadata::DESC_METADATA,
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
    Ddr::Batch::BatchObjectDatastream.create(
        batch_object: batch_object,
        name: Ddr::Models::File::CONTENT,
        operation: Ddr::Batch::BatchObjectDatastream::OPERATION_ADD,
        payload: full_filepath,
        payload_type: Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME,
        checksum: checksum_provider.checksum(rel_filepath),
        checksum_type: Ddr::Datastreams::CHECKSUM_TYPE_SHA1
    )
  end

end
