class BuildBatchFromNestedFolderIngest

  attr_reader :user, :filesystem, :content_modeler, :checksum_provider, :metadata_provider, :admin_set,
              :collection_title, :batch_name, :batch_description
  attr_accessor :batch, :collection_repo_id, :nested_path_base

  def initialize(user:, filesystem:, content_modeler:, checksum_provider:, metadata_provider: nil, admin_set: nil,
                 collection_repo_id: nil, collection_title: nil, batch_name: nil, batch_description: nil)
    @user = user
    @filesystem = filesystem
    @content_modeler = content_modeler
    @checksum_provider = checksum_provider
    @metadata_provider = metadata_provider
    @admin_set = admin_set
    @collection_repo_id = collection_repo_id
    @collection_title = collection_title
    @batch_name = batch_name
    @batch_description = batch_description
  end

  def call
    @batch = create_batch
    traverse_filesystem
    batch.update_attributes(status: Ddr::Batch::Batch::STATUS_READY,
                            collection_id: collection_repo_id,
                            collection_title: collection_title || collection_title_lookup)
    batch
  end

  private

  def collection_title_lookup
    collection_batch_objects = batch.batch_objects.where(model: 'Collection')
    if collection_batch_objects.present?
      collection_batch_object = collection_batch_objects.first
      titles = collection_batch_object.batch_object_attributes.where(name: 'title')
      titles.empty? ? nil : titles.first.value
    else
      Collection.find(collection_repo_id).title.first
    end
  rescue ActiveFedora::ObjectNotFoundError
    nil
  end

  def create_batch
    Ddr::Batch::Batch.create(user: user, name: batch_name, description: batch_description)
  end

  def traverse_filesystem
    filesystem.each do |node|
      node.content ||= {}
      object_model = content_modeler.new(node).call
      case object_model
        when 'Collection'
          collection_repo_id.present? ? node.content[:pid] = collection_repo_id : create_collection(node)
        when 'Component'
          pid = create_item(node)
          create_component(node, pid)
      end
    end
  end

  def create_collection(node)
    pid = assign_pid(node)
    self.collection_repo_id = pid
    batch_object = Ddr::Batch::IngestBatchObject.create(batch: batch, model: 'Collection', pid: pid)
    add_admin_policy_relationship(batch_object)
    add_attribute(batch_object, Ddr::Datastreams::ADMIN_METADATA, 'admin_set', admin_set)
    add_metadata(batch_object, nil) if metadata_provider.present?
    if batch_object.batch_object_attributes.where(name: 'title').empty?
      add_attribute(batch_object, Ddr::Datastreams::DESC_METADATA, 'title', collection_title)
    end
    add_role(batch_object)
  end

  def create_item(node)
    pid = assign_pid(node)
    batch_object = Ddr::Batch::IngestBatchObject.create(batch: batch, model: 'Item', pid: pid)
    add_admin_policy_relationship(batch_object)
    add_parent_relationship(batch_object, collection_repo_id)
    nested_path = File.join(nested_path_base, Filesystem.path_to_node(node, 'relative'))
    add_attribute(batch_object, Ddr::Datastreams::ADMIN_METADATA, 'nested_path', nested_path)
    add_metadata(batch_object, Filesystem.path_to_node(node)) if metadata_provider.present?
    pid
  end

  def create_component(node, item_pid)
    batch_object = Ddr::Batch::IngestBatchObject.create(batch: batch, model: 'Component')
    add_admin_policy_relationship(batch_object)
    add_parent_relationship(batch_object, item_pid)
    add_content_datastream(batch_object, node)
  end

  def assign_pid(node)
    node.content ||= {}
    node.content[:pid] = ActiveFedora::Base.connection_for_pid('0').mint
  end

  def add_metadata(batch_object, file_path)
    metadata = metadata_provider.metadata(file_path)
    metadata.each do |key, value|
      ds = Ddr::Datastreams::DescriptiveMetadataDatastream.term_names.include?(key.to_sym) ?
               Ddr::Datastreams::DESC_METADATA : Ddr::Datastreams::ADMIN_METADATA
      Array(value).each do |v|
        add_attribute(batch_object, ds, key, v)
      end
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

  def add_role(batch_object)
    Ddr::Batch::BatchObjectRole.create(
        batch_object: batch_object,
        operation: Ddr::Batch::BatchObjectRole::OPERATION_ADD,
        agent: user.user_key,
        role_type: Ddr::Auth::Roles::CURATOR.title,
        role_scope: Ddr::Auth::Roles::POLICY_SCOPE
    )
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
    filepath = Filesystem.path_to_node(node)
    ds = Ddr::Batch::BatchObjectDatastream.create(
      name: Ddr::Datastreams::CONTENT,
      operation: Ddr::Batch::BatchObjectDatastream::OPERATION_ADD,
      payload: filepath,
      payload_type: Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_FILENAME,
      checksum: checksum_provider.checksum(filepath),
      checksum_type: Ddr::Datastreams::CHECKSUM_TYPE_SHA1
    )
    batch_object.batch_object_datastreams << ds
  end

  def nested_path_base
    @nested_path_base ||= filesystem.root.name.split(File::SEPARATOR).last
  end

end
