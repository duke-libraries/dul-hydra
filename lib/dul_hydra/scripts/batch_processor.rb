module DulHydra::Scripts
  class BatchProcessor
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    
    def execute(opts={})
      log_file = opts.fetch(:log_file, File.join(Rails.root, 'log', 'batch_process.log'))
      log = config_logger(log_file)
      log.info "Batch Processor"
      log.info "DulHydra version: #{DulHydra::VERSION}"
      begin
        batch_id = opts.fetch(:batch_id)
        batch = Batch.find(batch_id)
      rescue KeyError
        log.error "Must specify :batch_id in options; e.g., :batch_id => 2"
      rescue ActiveRecord::RecordNotFound
        log.error "Unable to find batch with batch_id: #{batch_id}"
      end
      process_batch(batch, log) if batch
    end
    
    private
    
    def process_batch(batch, log)
      batch_run = BatchRun.create(:batch => batch, :status => BatchRun.NEW)
      objects = batch.batch_objects
      log.info "Batch size: #{objects.size}"
      batch_run.update_attributes(:status => BatchRun.RUNNING)
      objects.each { |object| process_object(object, log) }
      batch_run.update_attributes(:status => BatchRun.FINISHED)
    end
    
    def process_object(object, log)
      log.debug "Processing object: #{object.identifier}"
      log.debug "Operation: #{object.operation}"
      
      
    end
    
    def config_logger(log_file)
      logconfig = Log4r::YamlConfigurator
      logconfig['FILENAME'] = log_file
      logconfig.load_yaml_file File.join(LOG_CONFIG_FILEPATH)
      log = Log4r::Logger['batch']
    end
    
  end
end
