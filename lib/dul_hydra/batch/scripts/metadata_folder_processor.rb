require 'log4r'

module DulHydra::Batch::Scripts
  class MetadataFolderProcessor
    
    include ActionView::Helpers::TextHelper
    
    attr_accessor :collection, :logger, :scanner, :user
 
    INCLUDED_EXTENSIONS = [ '.xml' ]
    COLLECTION_ID_SEPARATOR = '_'
    VALID_NAMESPACE_DECLARATION_KEYS = 
      DulHydra::Datastreams::DescriptiveMetadataDatastream.xml_template.root.namespaces.keys <<
      "xmlns:xlink" <<
      "xmlns:xsi"
    METADATA_NAMESPACES = begin
      namespaces = {}
      DulHydra::Datastreams::DescriptiveMetadataDatastream.vocabularies.each do |vocab|
        namespaces[vocab::NAMESPACE_PREFIX] = vocab::XMLNS
      end
      namespaces
    end

    def initialize(opts={})
      @logger = config_logger
      @folder = opts.fetch(:folder)
      @collection = find_collection(opts[:collection]) if opts[:collection].present?
      @user = find_user(opts[:user]) if opts[:user].present?
      @scanner = {}
      @warnings = 0
      @errors = 0
    end
    
    def scan
      @logger.info("Scanning #{@folder}")
      scan_files(@folder)
      @logger.info(report)
    end
    
    def report
      raise "Nothing to report.  Maybe you need to run 'scan' first?" if @scanner.empty?
      rep = []
      rep << "Metadata Folder Scan"
      rep << "Scanned #{@folder}"
      rep << "Found #{pluralize(@scanner.keys.count, 'file')}"
      rep << "Found #{pluralize(count_dmdsecs, 'descriptive metadata section')}"
      if @collection.present?
        rep << "Collection #{@collection.title_display} has #{pluralize(@collection.items.count, 'item')}"
      end
      rep << "Scan generated #{pluralize(@warnings, 'WARNING', 'WARNINGS')} and #{pluralize(@errors, 'ERROR', 'ERRORS')}"
      rep.join("\n")
    end
    
    def create_batch
      batch = DulHydra::Batch::Models::Batch.create(user: @user, name: 'Metadata Folder', description: @folder)
      @scanner.keys.each do |file_loc|
        @scanner[file_loc].keys.each do |dmdsec_id|
          create_batch_object(batch, @scanner[file_loc][dmdsec_id])
        end
      end
      batch
    end
    
    private
    
    def create_batch_object(batch, scanner_object)
      batch_object = DulHydra::Batch::Models::UpdateBatchObject.create(
                        batch: batch, 
                        identifier: scanner_object[:id],
                        pid: scanner_object[:pid]
                        )
      create_batch_object_md_datastream(batch_object, scanner_object)
    end
    
    def create_batch_object_md_datastream(batch_object, scanner_object)
      DulHydra::Batch::Models::BatchObjectDatastream.create(
          batch_object: batch_object,
          name: DulHydra::Datastreams::DESC_METADATA,
          operation: DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADDUPDATE,
          payload: scanner_object[:md],
          payload_type: DulHydra::Batch::Models::BatchObjectDatastream::PAYLOAD_TYPE_BYTES
          )
    end

    def scan_files(dirpath)
      enumerator = Dir.foreach(dirpath)
      enumerator.each do |entry|
        unless [".", ".."].include?(entry)
          @file_loc = File.join(dirpath, entry)
          if File.directory?(@file_loc)
            scan_files(@file_loc)
          else
            harvest_metadata
          end
        end
      end
    end

    def harvest_metadata
      if INCLUDED_EXTENSIONS.include?(File.extname(@file_loc))
        @scanner[@file_loc] = {}
        doc = file_xml
        doc.xpath("//dmdSec").each do |dmdsec|
          dmdsec_id = dmdsec.attr("ID")
          obj_id = dmdsec_id.include?(COLLECTION_ID_SEPARATOR) ? 
                    dmdsec_id.partition(COLLECTION_ID_SEPARATOR).last :
                    dmdsec_id
          begin
            obj_pid = DulHydra::Utils.pid_for_identifier(obj_id, collection: @collection)
            warning("Repository object not found for identifier #{obj_id} in #{abbrev_file_loc}") unless obj_pid.present?
          rescue DulHydra::Error => e
            error(e.message)
          end
          source_metadata = dmdsec.xpath("mdWrap/xmlData")
          validate_source(source_metadata)
          obj_md = object_metadata(source_metadata, obj_id)
          @scanner[@file_loc][dmdsec_id] = { id: obj_id, pid: obj_pid, md: obj_md }
        end
      end
    end
    
    def object_metadata(xml_metadata, identifier)
      doc = DulHydra::Datastreams::DescriptiveMetadataDatastream.xml_template
      identifier_node = Nokogiri::XML::Node.new "dcterms:identifier", doc
      identifier_node.content = identifier
      doc.root.add_child(identifier_node)
      nodeset = xml_metadata.children
      nodeset.each do |node|
        doc.root << node
      end
      doc.to_xml
    end
    
    def validate_source(source_metadata)
      nodeset = source_metadata.children
      nodeset.each do |node|
        validate_namespace(node)
        validate_attributes(node)
        validate_elements(node)
      end
    end
    
    def validate_elements(node)
      if node.namespace.present?
        vocabulary = case node.namespace.prefix
        when DulHydra::Metadata::DCTerms::NAMESPACE_PREFIX
          DulHydra::Metadata::DCTerms
        when DulHydra::Metadata::DukeTerms::NAMESPACE_PREFIX
          DulHydra::Metadata::DukeTerms
        end
        if vocabulary.present?
          unless vocabulary::TERMS.include?(node.name.to_sym)
            error("Unknown element name #{node.name} in #{abbrev_file_loc}")              
          end
        else
          warning("Cannot validate element name #{node.name} in namespace #{node.namespace.prefix} in #{abbrev_file_loc}")
        end
      else
        warning("Cannot validate element name #{node.name} in #{abbrev_file_loc}")
      end
    end
    
    def validate_attributes(node)
      unless node.attributes.empty?
        node.attributes.keys.each do |attr_name|
          warning("Node #{node.name} in #{abbrev_file_loc} has attribute: #{attr_name}")
        end
      end
    end
    
    def validate_namespace(node)
      namespace = node.namespace
      unless namespace.present?
        error("Node #{node.name} in #{abbrev_file_loc} does not have a namespace")
      else
        unless METADATA_NAMESPACES.keys.include?(namespace.prefix)
          error("Node #{node.name} in #{abbrev_file_loc} has unknown namespace prefix: #{namespace.prefix}")
        else
          unless namespace.href == METADATA_NAMESPACES[namespace.prefix]
            error("Node #{node.name} in #{abbrev_file_loc} with namespace prefix #{namespace.prefix} has invalid href #{namespace.href}")
          end
        end
      end
    end
    
    def file_xml
      raw = File.read(@file_loc)
      doc = Nokogiri::XML(clean_namespace(raw)) { |config| config.noblanks }
      doc
    end
    
    def clean_namespace(source)
      source.gsub(%q[xmlns:dcterms="http://purl.org/dc/terms"], %q[xmlns:dcterms="http://purl.org/dc/terms/"])
    end
    
    def count_dmdsecs
      count = 0
      @scanner.each_key { |key| count += @scanner[key].keys.count }
      count
    end
    
    def find_collection(collection_option)
      case
      when collection_option.is_a?(Collection)
        collection_option
      when collection_option.is_a?(String)
        Collection.find(collection_option)
      end
    end
    
    def find_user(user_option)
      case
      when user_option.is_a?(User)
        user_option
      when user_option.is_a?(String)
        User.find_by_user_key(user_option)
      end
    end
    
    def abbrev_file_loc
      @file_loc.sub(/#{Regexp.quote(@folder)}\/?/, '')
    end
    
    def warning(message)
      @logger.warn(message)
      @warnings += 1
    end

    def error(message)
      @logger.error(message)
      @errors += 1
    end

    def config_logger
      logger = Log4r::Logger.new('metadata_file')
      logger.outputters << Log4r::Outputter.stdout
      logger
    end

  end
end