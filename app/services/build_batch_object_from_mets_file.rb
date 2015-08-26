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
    update_object = DulHydra::Batch::Models::UpdateBatchObject.create(batch: batch, pid: mets_file.repo_pid, identifier: mets_file.local_id)
    add_local_id(update_object) if mets_file.local_id.present?
    if display_format = METSFileDisplayFormat.get(mets_file, display_formats)
      add_display_format(update_object, display_format)
    end
    add_research_help_contact(update_object) if mets_file.repo_model == 'Collection' && mets_file.header_agent_id.present?
    add_desc_metadata(update_object) if mets_file.desc_metadata.present?
    add_struct_metadata(update_object) if mets_file.struct_metadata.present?
    update_object
  end

  def add_local_id(update_object)
    DulHydra::Batch::Models::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'local_id',
      operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_CLEAR)
    DulHydra::Batch::Models::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'local_id',
      value: mets_file.local_id,
      value_type: DulHydra::Batch::Models::BatchObjectAttribute::VALUE_TYPE_STRING,
      operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_ADD)
  end

  def add_display_format(update_object, display_format)
    DulHydra::Batch::Models::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'display_format',
      operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_CLEAR)
    DulHydra::Batch::Models::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'display_format',
      value: display_format,
      value_type: DulHydra::Batch::Models::BatchObjectAttribute::VALUE_TYPE_STRING,
      operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_ADD)
  end

  def add_research_help_contact(update_object)
    DulHydra::Batch::Models::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'research_contact',
      operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_CLEAR)
    DulHydra::Batch::Models::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::ADMIN_METADATA,
      name: 'research_help_contact',
      value: mets_file.header_agent_id,
      value_type: DulHydra::Batch::Models::BatchObjectAttribute::VALUE_TYPE_STRING,
      operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_ADD)
  end

  def add_desc_metadata(update_object)
    # To replicate existing behavior, which is that the metadata harvested from the metadata
    # folder completely replaces the existing metadata, first we need a directive to clear out
    # all existing metadata
    DulHydra::Batch::Models::BatchObjectAttribute.create(
      batch_object: update_object,
      datastream: Ddr::Datastreams::DESC_METADATA,
      operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_CLEAR_ALL
      )
    # Now we create the directives to add the attribute values from the METS file
    mets_file.desc_metadata_attributes_values.each do |entry|
      attr_name = entry.keys.first
      DulHydra::Batch::Models::BatchObjectAttribute.create(
        batch_object: update_object,
        datastream: Ddr::Datastreams::DESC_METADATA,
        operation: DulHydra::Batch::Models::BatchObjectAttribute::OPERATION_ADD,
        name: attr_name,
        value: entry[attr_name],
        value_type: DulHydra::Batch::Models::BatchObjectAttribute::VALUE_TYPE_STRING
        )
    end
  end

  def add_struct_metadata(update_object)
    DulHydra::Batch::Models::BatchObjectDatastream.create(
      batch_object: update_object,
      name: Ddr::Datastreams::STRUCT_METADATA,
      operation: DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADDUPDATE,
      payload: translate_struct_map(mets_file.struct_metadata),
      payload_type: DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES)
  end

  def translate_struct_map(mets_file_struct_map)
    structure = Ddr::Models::Structure.new(Ddr::Models::Structure.template)
    mets_file_struct_map.each do |node|
      add_to_struct_map(structure, node)
    end
    structure.to_xml
  end

  def add_to_struct_map(stru, node)
    div = create_div(stru, node)
    create_fptr(stru, div, Ddr::Utils.pid_for_identifier(div['ID']))
  end

  def create_div(stru, node)
    div = Nokogiri::XML::Node.new('div', stru.as_xml_document)
    node_attrs = node.attributes
    node_attrs.keys.each { |k| div[k] = node_attrs[k] }
    stru.structMap_node('default').add_child(div)
    div
  end

  def create_fptr(stru, div, pid)
    fptr = Nokogiri::XML::Node.new('fptr', stru.as_xml_document)
    fptr['CONTENTIDS'] = "info:fedora/#{pid}"
    div.add_child(fptr)
  end

end