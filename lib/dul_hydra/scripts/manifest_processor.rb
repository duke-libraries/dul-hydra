module DulHydra::Scripts
  class ManifestProcessor
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    DEFAULT_LOG_DIR = File.join(Rails.root, 'log')
    DEFAULT_LOG_FILE = "manifest_processor.log"
    
    MANIFEST_KEYS = [ :basepath, :batch, :description, :label, :model, :name, :objects, BatchObjectRelationship::RELATIONSHIPS ].flatten
    OBJECT_KEYS = [ :identifier, :label, :model, BatchObjectRelationships::RELATIONSHIPS].flatten

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
    
    def config_logger
      logconfig = Log4r::YamlConfigurator
      logconfig['LOG_DIR'] = @log_dir
      logconfig['LOG_FILE'] = @log_file
      logconfig.load_yaml_file File.join(LOG_CONFIG_FILEPATH)
      @log = Log4r::Logger['batch_processor']
    end
    
  end
end
