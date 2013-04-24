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
      batch_run = BatchRun.create(:batch => batch, :status => BatchRun::STATUS_NEW)
      objects = batch.batch_objects
      log.info "Batch size: #{objects.size}"
      batch_run.update_attributes(:status => BatchRun::STATUS_RUNNING)
      objects.each { |object| process_object(object, log) }
      batch_run.update_attributes(:status => BatchRun::STATUS_FINISHED)
    end
    
    def process_object(object, log)
      log.debug "Pre-validating batch object #{object.identifier} [database id: #{object.id}]"
      validation = object.validate
      if validation.valid?
        log.debug "Processing object: #{object.identifier}"
        log.debug "Operation: #{object.operation}"
        case object.operation
        when BatchObject::OPERATION_INGEST
          ingest(object, log)
        when BatchObject::OPERATION_UPDATE
          log.debug "Update not yet implemented"
        end
      else
        log.error "Batch object VALIDATION ERROR: #{object.identifier} NOT PROCESSED [database id: #{object.id}]"
        validation.errors.each { |error| log.error error }
      end      
    end
    
    def ingest(object, log)
        begin
          repo_object = object.model.constantize.new
          repo_object.label = object.label if object.label
          repo_object.admin_policy = AdminPolicy.find(object.admin_policy, :cast => true) if object.admin_policy
          object.batch_object_datastreams.each {|d| repo_object = add_datastream(repo_object, d, log)} if object.batch_object_datastreams
          repo_object.parent = ActiveFedora::Base.find(object.parent, :cast => true) if object.parent
          repo_object.collection = Collection.find(object.target_for, :cast => true) if object.target_for
          repo_object.save
        rescue => e
          log.error "Attempt to ingest #{object.model} #{object.identifier} FAILED: #{e.message}"
        else
          log.info "Ingested #{object.model} #{object.identifier} into #{repo_object.pid}"
#          create_preservation_event(PreservationEvent::INGESTION, PreservationEvent::SUCCESS, repo_object, object)
        end
    end
    
    def add_datastream(repo_object, datastream, log)
      case datastream[:payload_type]
      when BatchObjectDatastream::PAYLOAD_TYPE_BYTES
        repo_object.datastreams[datastream[:name]].content = datastream[:payload]
      when BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
        datastream_file = File.open(datastream[:payload])
        repo_object.datastreams[datastream[:name]].content_file = data_file
        repo_object.save # save the object to the repository before we close the file 
        data_file.close
      end
      repo_object.generate_thumbnail! if datastream[:name].eql?(DulHydra::Datastreams::CONTENT)
      return repo_object
    end
    
    def config_logger(log_file)
      logconfig = Log4r::YamlConfigurator
      logconfig['FILENAME'] = log_file
      logconfig.load_yaml_file File.join(LOG_CONFIG_FILEPATH)
      log = Log4r::Logger['batch_processor']
    end
    
  end
end
