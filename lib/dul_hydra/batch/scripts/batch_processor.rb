module DulHydra::Batch::Scripts
  class BatchProcessor
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    DEFAULT_LOG_DIR = File.join(Rails.root, 'log')
    DEFAULT_LOG_FILE = "batch_processor.log"
    PASS = "PASS"
    FAIL = "FAIL"
    
    # Options
    #   :batch_id - required - database id of batch to process
    #   :log_dir - optional - directory for log file - default is given in DEFAULT_LOG_DIR
    #   :log_file - optional - filename of log file - default is given in DEFAULT_LOG_FILE
    #   :dryrun - optional - whether this is a processing dry run or the real deal - default is false
    #   :skip_validation - optional - whether to skip batch object validation step when processing - default is false
    #   :ignore_validation_errors - optional - whether to continue processing even if batch object validation errors occur - default is false
    def initialize(opts={})
      begin
        @batch_id = opts.fetch(:batch_id)
      rescue KeyError
        puts "Must specify :batch_id in options; e.g., :batch_id => 2"
      end
      @log_dir = opts.fetch(:log_dir, DEFAULT_LOG_DIR)
      @log_file = opts.fetch(:log_file, DEFAULT_LOG_FILE)
      @dryrun = opts.fetch(:dryrun, false)
      @skip_validation = opts.fetch(:skip_validation, false)
      @ignore_validation_errors = opts.fetch(:ignore_validation_errors, false)
    end
    
    def execute
      config_logger
      begin
        @batch = DulHydra::Batch::Models::Batch.find(@batch_id)
      rescue ActiveRecord::RecordNotFound
        @log.error "Unable to find batch with batch_id: #{@batch_id}"
      end
      if @batch
        initiate_batch_run
        valid_batch = validate_batch unless @skip_validation
        if @skip_validation || @ignore_validation_errors || valid_batch
          process_batch
        end
        close_batch_run
      end
      save_logfile
      send_notification if @batch.user && @batch.user.email
    end
    
    private
    
    def validate_batch
      valid = true
      errors = @batch.validate
      unless errors.empty?
        valid = false
        errors.each do |error|
          message = "Batch Object Validation Error: #{error}"
          @details << message
          @log.error(message)
        end
      end
      return valid
    end
    
    def process_batch
      @batch.batch_objects.each { |object| process_object(object) }
    end
    
    def initiate_batch_run
      @log.info "Batch id: #{@batch.id}"
      @log.info "Batch name: #{@batch.name}" if @batch.name
      @log.info "Batch size: #{@batch.batch_objects.size}"
      @batch.start = DateTime.now
      @batch.status = DulHydra::Batch::Models::Batch::STATUS_RUNNING
      @batch.version = DulHydra::VERSION
      @failures = 0
      @successes = 0
      @details = []
    end
    
    def close_batch_run
      @batch.update_attributes(:details => @details.join("\n"),
                               :failure => @failures,
                               :outcome => @successes.eql?(@batch.batch_objects.size) ? DulHydra::Batch::Models::Batch::OUTCOME_SUCCESS : DulHydra::Batch::Models::Batch::OUTCOME_FAILURE,
                               :status => DulHydra::Batch::Models::Batch::STATUS_FINISHED,
                               :stop => DateTime.now,
                               :success => @successes)
      @log.info "Ingested #{@batch.success} of #{@batch.batch_objects.size} objects"
    end
    
    def process_object(object)
      @log.debug "Processing object: #{object.identifier}"
      results = object.process(:dryrun => @dryrun)
      if @dryrun
        @successes += 1 # need to think more about what a dry run failure would be and how to handle it
        message = "Dry run ingest attempt for #{object.model} #{object.identifier}"
      else
        object.verified ? @successes += 1 : @failures += 1
        message = object.results_message
      end
      @details << message
      @log.info(message)
    end
    
    def config_logger
      logconfig = Log4r::YamlConfigurator
      logconfig['LOG_FILE'] = File.join(@log_dir, @log_file)
      logconfig.load_yaml_file File.join(LOG_CONFIG_FILEPATH)
      @log = Log4r::Logger['batch_processor']
    end
    
    def save_logfile
      @log.outputters.each do |outputter|
        @logfilename = outputter.filename if outputter.respond_to?(:filename)
      end
      @batch.update_attributes({:logfile => File.new(@logfilename)}) if @logfilename
    end
    
    def send_notification
      begin
        BatchProcessorRunMailer.send_notification(@batch).deliver!
      rescue
        puts "An error occurred while attempting to send the notification."
      end
    end
    
  end
end
