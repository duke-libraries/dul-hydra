class BuildBatchFromFolderIngest

  attr_reader :user, :filesystem, :intermediate_files_name, :targets_name, :content_modeler, :metadata_provider,
              :checksum_provider, :admin_set, :batch_name, :batch_description
  attr_accessor :batch, :collection_repo_id

  def initialize(user:, filesystem:, intermediate_files_name: nil, targets_name: nil, content_modeler:,
                 metadata_provider: nil, checksum_provider:, admin_set: nil, collection_repo_id: nil, batch_name: nil,
                 batch_description: nil)
    @user = user
    @filesystem = filesystem
    @intermediate_files_name = intermediate_files_name
    @targets_name = targets_name
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
      object_model = content_modeler.new(node, intermediate_files_name, targets_name).call
      if object_model == 'Collection' && collection_repo_id.present?
        node.content[:pid] = collection_repo_id
      end
      if object_model
        create_object(node, object_model) unless node.content[:pid].present?
      end
    end
  end

  def create_object(node, object_model)
    pid = assign_pid(node) if ['Collection', 'Item'].include?(object_model)
    self.collection_repo_id = pid if object_model == 'Collection'
    batch_object = Ddr::Batch::IngestBatchObject.create(batch: batch, model: object_model, pid: pid)
    add_relationships(batch_object, node.parent)
    if admin_set.present? && object_model == 'Collection'
      add_attribute(batch_object, Ddr::Datastreams::ADMIN_METADATA, 'admin_set', admin_set)
    end
    add_role(batch_object) if object_model == 'Collection'
    add_metadata(batch_object, node) if metadata_provider
    add_content_datastream(batch_object, node) if [ 'Component', 'Target' ].include?(object_model)
    if object_model == 'Component' && intermediate_node = intermediate_file(node)
          add_intermediate_file_datastream(batch_object, intermediate_node)
    end
  end

  def assign_pid(node)
    node.content ||= {}
    node.content[:pid] = ActiveFedora::Base.connection_for_pid('0').mint
  end

  def add_relationships(batch_object, parent_node)
    add_admin_policy_relationship(batch_object)
    if [ 'Item', 'Component' ].include?(batch_object.model)
      add_parent_relationship(batch_object, parent_node.content[:pid])
    elsif batch_object.model == 'Target'
      add_collection_relationship(batch_object)
    end
  end

  def add_admin_policy_relationship(batch_object)
    Ddr::Batch::BatchObjectRelationship.create(
        batch_object: batch_object,
        name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_ADMIN_POLICY,
        operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD,
        object: collection_repo_id,
        object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_PID
    )
  end

  def add_parent_relationship(batch_object, parent_id)
    Ddr::Batch::BatchObjectRelationship.create(
        batch_object: batch_object,
        name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_PARENT,
        operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD,
        object: parent_id,
        object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_PID
    )
  end

  def add_collection_relationship(batch_object)
    Ddr::Batch::BatchObjectRelationship.create(
        batch_object: batch_object,
        name: Ddr::Batch::BatchObjectRelationship::RELATIONSHIP_COLLECTION,
        operation: Ddr::Batch::BatchObjectRelationship::OPERATION_ADD,
        object: collection_repo_id,
        object_type: Ddr::Batch::BatchObjectRelationship::OBJECT_TYPE_PID
    )
  end

  def add_role(batch_object)
    Ddr::Batch::BatchObjectRole.create(
        batch_object: batch_object,
        operation: Ddr::Batch::BatchObjectRole::OPERATION_ADD,
        agent: user.user_key,
        role_type: Ddr::Auth::Roles::CURATOR.title,
        role_scope: Ddr::Auth::Roles::POLICY_SCOPE
    )
  end

  def add_metadata(batch_object, node)
    locator = Filesystem.node_locator(node)
    metadata_provider.metadata(locator).each do |key, value|
      ds = Ddr::Datastreams::DescriptiveMetadataDatastream.term_names.include?(key.to_sym) ?
                                                    Ddr::Datastreams::DESC_METADATA : Ddr::Datastreams::ADMIN_METADATA
      Array(value).each do |v|
        add_attribute(batch_object, ds, key, v)
      end
    end
  end

  def add_attribute(batch_object, datastream, term, value)
    Ddr::Batch::BatchObjectAttribute.create(
        batch_object: batch_object,
        datastream: datastream,
        name: term,
        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
        value: value,
        value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
    )
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
      checksum_type: Ddr::Datastreams::CHECKSUM_TYPE_SHA1
    )
    batch_object.batch_object_datastreams << ds
  end

  def add_intermediate_file_datastream(batch_object, node)
    full_filepath = Filesystem.path_to_node(node)
    rel_filepath = Filesystem.path_to_node(node, 'relative')
    ds = Ddr::Batch::BatchObjectDatastream.create(
        name: Ddr::Datastreams::INTERMEDIATE_FILE,
        operation: Ddr::Batch::BatchObjectDatastream::OPERATION_ADD,
        payload: full_filepath,
        payload_type: Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME,
        checksum: checksum_provider.checksum(rel_filepath),
        checksum_type: Ddr::Datastreams::CHECKSUM_TYPE_SHA1
    )
    batch_object.batch_object_datastreams << ds
  end

  def intermediate_file(node)
    if intermediate_files_name.present?
      @intermediates ||= filesystem.root[intermediate_files_name]
      @intermediates.children.select { |chld| File.basename(chld.name, '.*') == File.basename(node.name, '.*') }.first
    end
  end
end
