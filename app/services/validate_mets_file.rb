class ValidateMETSFile

  attr_accessor :results
  attr_reader :mets_file

  Results = Struct.new(:warnings, :errors)

  METADATA_NAMESPACES = { "dcterms"=>"http://purl.org/dc/terms/", "duke"=>"http://library.duke.edu/metadata/terms" }

  def initialize(mets_file)
    @mets_file = mets_file
    @results = Results.new
    results.warnings = []
    results.errors = []
  end

  def call
    validate_file
  end

  private

  def validate_file
    validate_repository_match
    validate_root_type_attribute
    validate_desc_metadata
    validate_struct_metadata
    results
  end

  def validate_repository_match
    warning("Repository object not found for local id #{mets_file.local_id}") unless mets_file.repo_pid.present?
  end

  def validate_root_type_attribute
    warning('Missing TYPE attribute on root node') unless mets_file.root_type_attr.present?
  end

  def validate_desc_metadata
    case mets_file.dmd_secs.size
    when 0
      warning("No dmdSec")
    when 1
      validate_dmd_sec
    else
      error("Multiple dmdSecs")
    end
  end

  def validate_dmd_sec
    mets_file.desc_metadata.each do |node|
      validate_dmd_namespace(node)
      validate_dmd_attributes(node)
      validate_dmd_elements(node)
    end
  end

  def validate_dmd_namespace(node)
    namespace = node.namespace
    unless namespace.present?
      error("Node #{node.name} does not have a namespace")
    else
      unless METADATA_NAMESPACES.keys.include?(namespace.prefix)
        error("Node #{node.name} has unknown namespace prefix: #{namespace.prefix}")
      else
        unless namespace.href == METADATA_NAMESPACES[namespace.prefix]
          error("Node #{node.name} with namespace prefix #{namespace.prefix} has invalid href #{namespace.href}")
        end
      end
    end
  end

  def validate_dmd_attributes(node)
    unless node.attributes.empty?
      node.attributes.keys.each do |attr_name|
        warning("Node #{node.name} has attribute: #{attr_name}")
      end
    end
  end

  def validate_dmd_elements(node)
    if node.namespace.present?
      vocabulary = case node.namespace.prefix
      when "dcterms"
        RDF::DC
      when "duke"
        Ddr::Vocab::DukeTerms
      end
      if vocabulary.present?
        unless Ddr::Vocab::Vocabulary.term_names(vocabulary).include?(node.name.to_sym)
          error("Unknown element name #{node.name}")
        end
      else
        warning("Cannot validate element name #{node.name} in namespace #{node.namespace.prefix}")
      end
    else
      warning("Cannot validate element name #{node.name}")
    end
  end

  def validate_struct_metadata
    case mets_file.struct_maps.size
    when 0
      warning("No structMap")
    when 1
      validate_struct_map
    else
      error("Multiple structMaps")
    end
  end

  def validate_struct_map
    mets_file.struct_metadata.each do |node|
      validate_div(node)
    end
  end

  def validate_div(node)
    div_id_attr = node.attr('ID')
    if div_id_attr.present?
      unless Ddr::Utils.pid_for_identifier(div_id_attr)
        error("Unable to locate repository object for div ID #{div_id_attr}")
      end
    else
      error("Div does not have ID attribute")
    end
  end

  def error(message)
    results.errors << "#{mets_file.filepath}: #{message}"
  end

  def warning(message)
    results.warnings << "#{mets_file.filepath}: #{message}"
  end

end