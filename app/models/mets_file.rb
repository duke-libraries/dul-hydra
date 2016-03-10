class METSFile

  attr_reader :filepath

  COLLECTION_ID_SEPARATOR = '_'
  DISPLAY_FORMAT_TYPE_SEPARATOR = ':'
  SOURCE_IDS_SEPARATOR = '/'

  SourceIds = Struct.new(:ead_id, :aspace_id)

  def initialize(filepath, collection=nil)
    @filepath = filepath
    @collection = collection
  end

  def local_id
    @local_id ||= id_attr.split(COLLECTION_ID_SEPARATOR).last
  end

  def collection_id
    @collection_id ||= id_attr.split(COLLECTION_ID_SEPARATOR).first
  end

  def collection
    @collection ||= ActiveFedora::Base.find(Ddr::Utils.pid_for_identifier(collection_id), model: 'Collection')
  end

  def repo_pid
    @repo_pid ||= Ddr::Utils.pid_for_identifier(local_id, collection: collection)
  end

  def repo_model
    @repo_model ||= model(repo_pid)
  end

  def root_type_attr
    @root_type_attr ||= mets_doc.root.attr('TYPE')
  end

  def header_agent_id
    @header_agent_id ||= mets_hdr_agent_id_attr.value if mets_hdr_agent_id_attr
  end

  def amd_secs
    @amd_secs ||= mets_doc.xpath('//amdSec')
  end

  def ead_id
    @ead_id ||= source_ids.ead_id if source_ids
  end

  def aspace_id
    @aspace_id ||= source_ids.aspace_id if source_ids
  end

  def dmd_secs
    @dmd_secs ||= mets_doc.xpath('//dmdSec')
  end

  def dmd_sec
    dmd_secs.first
  end

  def desc_metadata
    @desc_metadata ||= dmd_sec.xpath('mdWrap/xmlData').children
  end

  def desc_metadata_attributes_values
    desc_metadata.map { |node| { node.name => node.content } }
  end

  def struct_maps
    @struct_maps ||= mets_doc.xpath('//structMap')
  end

  def struct_map
    struct_maps.first
  end

  def struct_metadata
    @struct_metadata ||= struct_map.xpath('div') if struct_map.present?
  end

  def struct_metadata_fptr_nodes
    struct_metadata.xpath('//fptr')
  end

  private

  def mets_doc
    @mets_doc ||= file_xml_doc
  end

  def file_xml_doc
    raw = File.read(filepath)
    Nokogiri::XML(clean_namespace(raw)) { |config| config.noblanks }
  end

  def clean_namespace(source)
    source.gsub(%q[xmlns:dcterms="http://purl.org/dc/terms"], %q[xmlns:dcterms="http://purl.org/dc/terms/"])
  end

  def id_attr
    @id_attr ||= mets_doc.root.attr('ID')
  end

  def model(pid)
    q = ActiveFedora::SolrQueryBuilder.construct_query_for_ids([ pid ])
    r = ActiveFedora::SolrService.query(q)
    r.first[Ddr::Index::Fields::ACTIVE_FEDORA_MODEL] unless r.empty?
  end

  def mets_hdr
    @mets_hdr ||= mets_doc.xpath('//metsHdr')
  end

  def mets_hdr_agent
    @mets_hdr_agent ||= mets_hdr.xpath('agent') if mets_hdr.present?
  end

  def mets_hdr_agent_id_attr
    @mets_hdr_agent_id_attr ||= mets_hdr_agent.attr('ID') if mets_hdr_agent.present?
  end

  def amd_sec
    amd_secs.first
  end

  def source_metadata
    @source_metadata ||= amd_sec.xpath('sourceMD/mdWrap/xmlData') if amd_sec.present?
  end

  def source_ids_element
    @source_ids_element ||= source_metadata.xpath('dcterms:source').first if source_metadata.present?
  end

  def source_ids
    @source_ids ||= SourceIds.new(*source_ids_element.content.split(SOURCE_IDS_SEPARATOR)) if source_ids_element
  end

end
