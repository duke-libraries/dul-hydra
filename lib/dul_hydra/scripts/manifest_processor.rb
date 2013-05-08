module DulHydra::Scripts
  class ManifestProcessor
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    DEFAULT_LOG_DIR = File.join(Rails.root, 'log')
    DEFAULT_LOG_FILE = "manifest_processor.log"
    
    MANIFEST_KEYS = [ :basepath, :batch, :checksum, :description, :label, :model, :name, :objects, BatchObjectRelationship::RELATIONSHIPS ].flatten
    BATCH_KEYS = [ :description, :id, :name ]
    MANIFEST_CHECKSUM_KEYS = [ :location, :source, :type, :node_xpath, :identifier_element, :type_xpath, :value_xpath ] # if :location, must include :checksum_xpath and :identifier_element
    MANIFEST_DATASTREAM_KEYS = [ :extension, :location ]
    OBJECT_KEYS = [ :identifier, :label, :model, BatchObjectDatastreams::DATASTREAMS, BatchObjectRelationships::RELATIONSHIPS].flatten
    OBJECT_CHECKSUM_KEYS = [ :type, :value ]

    # Options
    #   :manifest - required - manifest file path and filename
    #   :log_dir - optional - directory for log file - default is given in DEFAULT_LOG_DIR
    #   :log_file - optional - filename of log file - default is given in DEFAULT_LOG_FILE
    #   :dryrun - optional - whether this is a processing dry run or the real deal - default is false
    def initialize(opts={})
      begin
        @manifest_file = opts.fetch(:manifest)
      rescue KeyError
        puts "Must specify :manifest in options; e.g., :manifest => /path/to/manifest.yml"
      end
      @log_dir = opts.fetch(:log_dir, DEFAULT_LOG_DIR)
      @log_file = opts.fetch(:log_file, DEFAULT_LOG_FILE)
      @dryrun = opts.fetch(:dryrun, false)
    end
    
    def execute
      config_logger
      @manifest = load_manifest(@manifest_file)
      if @manifest
        begin
          if @manifest[:batch]
            @batch = Batch.find(@manifest[:batch].to_i)
          else
            @batch = Batch.create(:name => @manifest[:name], :description => @manifest[:description])
          end
        rescue ActiveRecord::RecordNotFound
          log.error("Cannot find Batch with id #{@manifest[:batch]}")
        end
        process_manifest if @batch
      end
    end
    
    private

    def process_manifest
      objects = @manifest[:objects]
      objects.each { |obj| process_object(obj) }
    end
    
    def process_object(manifest_object)
      batch_object = IngestBatchObject.create(:batch => @batch)
      batch_object.identifier = key_identifier(manifest_object)
      batch_object.label = manifest_object[:label] || @manifest[:label]
      batch_object.model = manifest_object[:model] || @manifest[:model]
      create_batch_object_datastreams(manifest_object, batch_object)
      create_batch_object_relationships(manifest_object, batch_object)
      batch_object.save
    end
    
    def create_batch_object_datastreams(manifest_object, batch_object)
      if @manifest[:checksum]
        checksums = File.open(@manifest[:checksum][:location]) { |f| Nokogiri::XML(f) }
      end
      datastreams = manifest_object[:datastreams] || @manifest[:datastreams]
      datastreams.each do |datastream|
        name = datastream
        operation = BatchObjectDatastream::OPERATION_ADD
        payload = case
          # canonical location is @manifest[:basepath] + datastream (name)
          # canonical filename is batch_object.identifier
          # canonical extension is ".xml"
        when manifest_object[datastream].nil?
          # (manifest datastream location || canonical location) + canonical filename + (manifest datastream extension || canonical extension)
          location = @manifest[datastream][:location] || @manifest[:basepath] + datastream
          extension = @manifest[datastream][:extension] || ".xml"
          location + batch_object.identifier + extension
        when manifest_object[datastream].start_with?(File::PATH_SEPARATOR)
          # manifest_object[datastream] contains full path, file name, and extension
          manifest_object[datastream]
        else
          # (manifest datastream location || canonical location) + manifest_object[datastream]
          location = @manifest[datastream][:location] || @manifest[:basepath] + datastream
          location + manifest_object[datastream]
        end
        payload_type = BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
        checksum = case
        when manifest_object[:checksum][:value]
          # manifest_object[:checksum][:value]
          manifest_object[:checksum][:value]
        when manifest_object[:checksum]
          # manifest_object[:checksum]
          manifest_object[:checksum]
        when checksums
          # read checksum from XML document
          node = node_from_document(checksums,
                                    @manifest[:checksum][:node_xpath],
                                    @manifest[:checksum][:identifier_element],
                                    manifest_object[:identifier])
          text_from_node(node, @manifest[:checksum][:value_xpath])
        end
        checksum_type = case
        when manifest_object[:checksum][:type]
          # manifest_object[:checksum][:type]
          manifest_object[:checksum][:type]
        when checksums
          # read checksum type from XML document
          node = node_from_document(checksums,
                                    @manifest[:checksum][:node_xpath],
                                    @manifest[:checksum][:identifier_element],
                                    manifest_object[:identifier])
          text_from_node(node, @manifest[:checksum][:type_xpath])
        when @manifest[:checksum][:type]
          # @manifest[:checksum][:type]
          @manifest[:checksum][:type]
        end
        batch_object = batch_object
        ds = BatchObjectDatastream.create(:name => name,
                                          :operation => operation,
                                          :payload => payload,
                                          :payload_type => payload_type,
                                          :batch_object => batch_object)
        ds.checksum = checksum if checksum
        ds.checksum_type = checksum_type if checksum_type
        ds.save
      end
    end
    
    def create_batch_object_relationships(manifest_object, batch_object)
      BatchObjectRelationship::RELATIONSHIPS.each do |relationship|
        relationship_object = manifest_object[relationship] || @manifest[relationship]
        if relationship_object
          BatchObjectRelationship.create(:name => relationship,
                                         :object => relationship_object,
                                         :object_type => BatchObjectRelationship::OBJECT_TYPE_PID,
                                         :operation => BatchObjectRelationship::OPERATION_ADD,
                                         :batch_object => batch_object)
        end
      end
    end
    
    def key_identifier(object)
      case object[:identifier]
      when String
        object[:identifier]
      when Array
        object[:identifier].first
      end
    end

    def load_manifest(manifest_file)
      File.open(manifest_file) { |f| YAML::load(f) }
    end
    
    def text_from_node(node, element_xpath)
      node.xpath(element_xpath).text()
    end
    
    def node_from_document(document, node_xpath, test_element, test_value)
      document.xpath("#{xpath}[#{test_element}[text() = '#{test_value}']]")
    end

    def config_logger
      logconfig = Log4r::YamlConfigurator
      logconfig['LOG_DIR'] = @log_dir
      logconfig['LOG_FILE'] = @log_file
      logconfig.load_yaml_file File.join(LOG_CONFIG_FILEPATH)
      @log = Log4r::Logger['batch_processor']
    end
    
  end
end
