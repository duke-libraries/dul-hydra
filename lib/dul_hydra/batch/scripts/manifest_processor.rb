module DulHydra::Batch::Scripts
  class ManifestProcessor
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    DEFAULT_LOG_DIR = File.join(Rails.root, 'log')
    DEFAULT_LOG_FILE = "manifest_processor.log"
    
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
      begin
        @log.info("Processing manifest: #{@manifest_file}")
        manifest = Manifest.new(@manifest_file)
        @log.info("Manifest name: #{manifest.name}")
        set_batch(manifest)
        @log.debug("Batch id: #{manifest.batch.id}")
        manifest.objects.each { |object| process_object(object) }
      rescue Exception => e
        @log.error(e.message)
        @log.debug(e.backtrace)
      end
    end
    
    private
    
    def set_batch(manifest)
      begin
        if manifest.batch_id
          batch = Batch.find(manifest.batch_id)
        else
          name = manifest.batch_name
          description = manifest.batch_description
          user = find_user(manifest.batch_user_email) if manifest.batch_user_email
          batch = Batch.create(:name => name, :description => description, :user => user)
        end
      rescue ActiveRecord::RecordNotFound
        @log.error("Cannot find Batch with id #{manifest_hash[BATCH][ID]}")
      end
      manifest.batch = batch
    end

    def find_user(user_email)
      users = User.where("email = ?", user_email)
      if users.size.eql?(1)
        user = users.first
      else
        @log.error("Cannot find User with email #{user_email}")
      end
      return user
    end
    
    def process_object(manifest_object)
      @log.debug("Processing manifest object #{manifest_object.key_identifier}")
      batch_object = IngestBatchObject.create(:batch => manifest_object.batch)
      batch_object.identifier = manifest_object.key_identifier
      batch_object.label = manifest_object.label
      batch_object.model = manifest_object.model
      create_batch_object_datastreams(manifest_object, batch_object)
      create_batch_object_relationships(manifest_object, batch_object)
      batch_object.save
      @log.info("Processed manifest object #{manifest_object.key_identifier} into batch object #{batch_object.id}")
    end
    
    def create_batch_object_datastreams(manifest_object, batch_object)
      manifest_object.datastreams.each do |datastream|
        @log.debug("... datastream #{datastream}")
        name = datastream
        operation = BatchObjectDatastream::OPERATION_ADD
        payload = manifest_object.datastream_filepath(datastream)
        payload_type = BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
        ds = BatchObjectDatastream.create(:name => name,
                                          :operation => operation,
                                          :payload => payload,
                                          :payload_type => payload_type,
                                          :batch_object => batch_object)
        # For now, we assume that the only datastream for which we might have a checksum
        # in the DulHydra::Datastreams::CONTENT datastream
        if datastream.eql?(DulHydra::Datastreams::CONTENT)
          ds.checksum = manifest_object.checksum if manifest_object.checksum?
          ds.checksum_type = manifest_object.checksum_type if manifest_object.checksum_type?
        end
        ds.save
      end
    end
    
    def create_batch_object_relationships(manifest_object, batch_object)
      BatchObjectRelationship::RELATIONSHIPS.each do |relationship|
        if manifest_object.has_relationship?(relationship)
          @log.debug("... relationship #{relationship}")
          relationship_object_pid = manifest_object.relationship_pid(relationship)
          if relationship_object_pid
            BatchObjectRelationship.create(:name => relationship,
                                           :object => manifest_object.relationship_pid(relationship),
                                           :object_type => BatchObjectRelationship::OBJECT_TYPE_PID,
                                           :operation => BatchObjectRelationship::OPERATION_ADD,
                                           :batch_object => batch_object)
          else
            @log.error("Could not create #{relationship} for #{manifest_object.key_identifier}")
            @log.error("Could not find pid for relationship object")
          end
        end
      end
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
