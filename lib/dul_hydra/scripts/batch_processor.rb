module DulHydra::Scripts
  class BatchProcessor
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    DEFAULT_LOG_DIR = File.join(Rails.root, 'log')
    DEFAULT_LOG_FILE = "batch_processor.log"
    PASS = "PASS"
    FAIL = "FAIL"
    
    def initialize(opts={})
      begin
        @batch_id = opts.fetch(:batch_id)
      rescue KeyError
        @log.error "Must specify :batch_id in options; e.g., :batch_id => 2"
      end
      @log_dir = opts.fetch(:log_dir, DEFAULT_LOG_DIR)
      @log_file = opts.fetch(:log_file, DEFAULT_LOG_FILE)
      @dryrun = opts.fetch(:dryrun, false)
    end
    
    def execute
      config_logger
      begin
        @batch = Batch.find(@batch_id)
      rescue ActiveRecord::RecordNotFound
        @log.error "Unable to find batch with batch_id: #{@batch_id}"
      end
      process_batch if @batch
    end
    
    private
    
    def process_batch
      initiate_batch_run(@batch)
      @batch.batch_objects.each { |object| process_object(object) }
      close_batch_run
    end
    
    def initiate_batch_run(batch)
      @log.info "Batch size: #{@batch.batch_objects.size}"
      @batch_run = BatchRun.create(:batch => @batch,
                                   :start => DateTime.now,
                                   :status => BatchRun::STATUS_RUNNING,
                                   :total => batch.batch_objects.size,
                                   :version => DulHydra::VERSION)
      @failures = 0
      @successes = 0
      @details = []
    end
    
    def close_batch_run
#      details = @ingest_details + @validation_details
      details = []
      @batch_run.update_attributes(:details => details.join("\n"),
                                   :failure => @failures,
                                   :outcome => @successes.eql?(@batch_run.total) ? BatchRun::OUTCOME_SUCCESS : BatchRun::OUTCOME_FAILURE,
                                   :status => BatchRun::STATUS_FINISHED,
                                   :stop => DateTime.now,
                                   :success => @successes)
      @log.info "Ingested #{@batch_run.success} of #{@batch_run.total} objects"
    end
    
    def process_object(object)
      @log.debug "Pre-validating batch object #{object.identifier} [database id: #{object.id}]"
      validation = object.validate
      if validation.valid?
        @log.debug "Processing object: #{object.identifier}"
        @log.debug "Operation: #{object.operation}"
        case object.operation
        when BatchObject::OPERATION_INGEST
          repo_object, verified, verifications = object.process(:dryrun => @dryrun)
          verified ? @successes += 1 : @failures += 1
        when BatchObject::OPERATION_UPDATE
          @log.debug "Update not yet implemented"
          @failures += 1
        end
      else
        @log.error "Batch object VALIDATION ERROR: #{object.identifier} NOT PROCESSED [database id: #{object.id}]"
        validation.errors.each { |error| log.error error }
        @failures += 1
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
