class BuildBatchObjectFromMETSFile

  attr_reader :batch, :mets_file, :display_formats

  def initialize(batch:, mets_file:, display_formats: {})
    @batch = batch
    @mets_file = mets_file
    @display_formats = display_formats
  end

  def call
    create_update_object
  end

  private

  def create_update_object
    update_object = Ddr::Batch::UpdateBatchObject.create(batch: batch, pid: mets_file.repo_pid, identifier: mets_file.local_id)
    add_local_id(update_object) if mets_file.local_id.present?
    if display_format = METSFileDisplayFormat.get(mets_file, display_formats)
      add_display_format(update_object, display_format)
    end
    add_research_help_contact(update_object) if mets_file.repo_model == 'Collection' && mets_file.header_agent_id.present?
    add_desc_metadata(update_object) if mets_file.desc_metadata.present?
    add_ead_id(update_object) if mets_file.ead_id.present?
    add_aspace_id(update_object) if mets_file.aspace_id.present?
    add_struct_metadata(update_object) if mets_file.struct_metadata.present?
    update_object
  end

  def add_local_id(update_object)
    Ddr::Batch::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'local_id',
      operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR)
    Ddr::Batch::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'local_id',
      value: mets_file.local_id,
      value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING,
      operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD)
  end

  def add_display_format(update_object, display_format)
    Ddr::Batch::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'display_format',
      operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR)
    Ddr::Batch::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'display_format',
      value: display_format,
      value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING,
      operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD)
  end

  def add_research_help_contact(update_object)
    Ddr::Batch::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'research_help_contact',
      operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR)
    Ddr::Batch::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'research_help_contact',
      value: mets_file.header_agent_id,
      value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING,
      operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD)
  end

  def add_desc_metadata(update_object)
    # To replicate existing behavior, which is that the metadata harvested from the metadata
    # folder completely replaces the existing metadata, first we need a directive to clear out
    # all existing metadata
    Ddr::Batch::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::DESC_METADATA,
      operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR_ALL
      )
    # Now we create the directives to add the attribute values from the METS file
    mets_file.desc_metadata_attributes_values.each do |entry|
      attr_name = entry.keys.first
      Ddr::Batch::BatchObjectAttribute.create(
        batch_object: update_object,
        datastream: Ddr::Datastreams::DESC_METADATA,
        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD,
        name: attr_name,
        value: entry[attr_name],
        value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING
        )
    end
  end

  def add_ead_id(update_object)
    Ddr::Batch::BatchObjectAttribute.create(
        batch_object: update_object,
        datastream: Ddr::Datastreams::ADMIN_METADATA,
        name: 'ead_id',
        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR)
    Ddr::Batch::BatchObjectAttribute.create(
        batch_object: update_object,
        datastream: Ddr::Datastreams::ADMIN_METADATA,
        name: 'ead_id',
        value: mets_file.ead_id,
        value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING,
        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD)
  end

  def add_aspace_id(update_object)
    Ddr::Batch::BatchObjectAttribute.create(
        batch_object: update_object,
        datastream: Ddr::Datastreams::ADMIN_METADATA,
        name: 'aspace_id',
        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_CLEAR)
    Ddr::Batch::BatchObjectAttribute.create(
        batch_object: update_object,
        datastream: Ddr::Datastreams::ADMIN_METADATA,
        name: 'aspace_id',
        value: mets_file.aspace_id,
        value_type: Ddr::Batch::BatchObjectAttribute::VALUE_TYPE_STRING,
        operation: Ddr::Batch::BatchObjectAttribute::OPERATION_ADD)
  end

  def add_struct_metadata(update_object)
    Ddr::Batch::BatchObjectDatastream.create(
      batch_object: update_object,
      name: Ddr::Datastreams::STRUCT_METADATA,
      operation: Ddr::Batch::BatchObjectDatastream::OPERATION_ADDUPDATE,
      payload: translate_struct_map(mets_file),
      payload_type: Ddr::Batch::BatchObjectDatastream::PAYLOAD_TYPE_BYTES)
  end

  def translate_struct_map(mets_file)
    mets_file.struct_metadata_fptr_nodes.each do |ptr_node|
      update_ptr(ptr_node)
    end
    structure = Ddr::Models::Structure.new(Ddr::Models::Structure.xml_template)
    structure.root.add_child(mets_file.struct_map.to_xml)
    structure.to_xml
  end

  def update_ptr(ptr_node)
    local_id = ptr_node['fileID']
    pid = Ddr::Utils.pid_for_identifier(local_id, model: 'Component')
    permanent_id = SolrDocument.find(pid).permanent_id
    ptr_node.name = 'mptr'
    ptr_node['LOCTYPE'] = 'ARK'
    ptr_node['xlink:href'] = permanent_id
    ptr_node.attributes['fileID'].remove
  end

end
