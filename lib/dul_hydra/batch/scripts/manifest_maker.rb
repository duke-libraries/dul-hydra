module DulHydra::Batch::Scripts
  class ManifestMaker
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    DEFAULT_LOG_DIR = File.join(Rails.root, 'log')
    DEFAULT_LOG_FILE = "manifest_maker.log"
    DEFAULT_MODEL = "Component"
    DEFAULT_DATASTREAMS = [ "content" ]
    DEFAULT_CONTENT_EXTENSION = ".tif"
    PLACEHOLDER = "PLACEHOLDER VALUE - replace with actual value or remove this entry"
    
    # Options
    #   :dirpath - required - path to directory containing files on which manifest is to be based
    #   :manifest - required - path and filename of manifest to make
    #   :extension - optional - extension of files to include - default is given in DEFAULT_CONTENT_EXTENSION
    #   :log_dir - optional - directory for log file - default is given in DEFAULT_LOG_DIR
    #   :log_file - optional - filename of log file - default is given in DEFAULT_LOG_FILE
    def initialize(opts={})
      begin
        @dirpath = opts.fetch(:dirpath)
      rescue KeyError
        puts "Must specify :dirpath in options; e.g., :dirpath => /path/to/files/"
      end
      begin
        @manifest = opts.fetch(:manifest)
      rescue KeyError
        puts "Must specify :manifest in options; e.g., :manifest => /path/to/manifest.yml"
      end
      @extension = opts.fetch(:extension, DEFAULT_CONTENT_EXTENSION)
      @log_dir = opts.fetch(:log_dir, DEFAULT_LOG_DIR)
      @log_file = opts.fetch(:log_file, DEFAULT_LOG_FILE)
    end
    
    def execute
      config_logger
      begin
        @log.info("Processing directory: #{@dirpath}")
        @log.info("Making manifest: #{@manifest}")
        @manifest_hash = {}
        build_manifest_level
        enumerate_objects
        @log.debug(@manifest_hash)
        write_manifest
      rescue Exception => e
        @log.error(e.message)
        @log.debug(e.backtrace)
      end
    end

    private
    
    def build_manifest_level
      @manifest_hash["model"] = DEFAULT_MODEL
      @manifest_hash["basepath"] = PLACEHOLDER
      @manifest_hash["datastreams"] = DEFAULT_DATASTREAMS
      content_hash = {}
      content_hash["extension"] = @extension
      content_hash["location"] = @dirpath
      @manifest_hash["content"] = content_hash
    end
    
    def enumerate_objects
      objects_list = []
      files = Dir.glob(File.join(@dirpath, '*')).select{|x| test(?f,x)}
      files.each do |file|
        if File.extname(file).eql?(@extension)
          base_filename = File.basename(file, File.extname(file))
          objects_list << { "identifier" => base_filename }
        end
      end
      @manifest_hash["objects"] = objects_list
    end
    
    def write_manifest
      File.open(@manifest, 'w') { |f| f.write(@manifest_hash.to_yaml) }
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
