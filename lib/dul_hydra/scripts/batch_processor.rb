module DulHydra::Scripts
  class BatchProcessor
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    DEFAULT_LOG_DIR = File.join(Rails.root, 'log')
    DEFAULT_LOG_FILE = "batch_processor.log"
    PASS = "PASS"
    FAIL = "FAIL"
    
    PRESERVATION_EVENT_DETAIL = <<-EOS
      DulHydra version #{DulHydra::VERSION}
      %{operation}
      Batch object database id: %{batch_id}
      Batch object identifier: %{identifier}
      Model: %{model}
    EOS
    
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
      details = @ingest_details + @validation_details
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
          repo_object, verifications = object.ingest(:dryrun => @dryrun)
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
    
    def ingest(object)
      outcome_details = []
      begin
        repo_object = object.model.constantize.new
        repo_object.label = object.label if object.label
        repo_object.admin_policy = AdminPolicy.find(object.admin_policy, :cast => true) if object.admin_policy
        object.batch_object_datastreams.each {|d| repo_object = add_datastream(repo_object, d)} if object.batch_object_datastreams
        repo_object.parent = ActiveFedora::Base.find(object.parent, :cast => true) if object.parent
        repo_object.collection = Collection.find(object.target_for, :cast => true) if object.target_for
        repo_object.save
      rescue => e
        detail = "Attempt to ingest #{object.model} #{object.identifier} FAILED: #{e.message}"
        @log.error detail
        outcome_details << detail
      else
        detail = "Ingested #{object.model} #{object.identifier} into #{repo_object.pid}"
        @log.info detail
        outcome_details << detail
        object.update_attributes(:pid => repo_object.pid)
        create_preservation_event(PreservationEvent::INGESTION, PreservationEvent::SUCCESS, outcome_details, repo_object, object)
      end
      @details += outcome_details
    end
    
    def validate(object)
      outcome_details = []
      valid = true
      validations = {}
      if object.pid
        repo_object = ActiveFedora::Base.find(object.pid, :cast => true)
        if object.operation.eql? BatchObject::OPERATION_INGEST
          valid = validate_model(object, repo_object)
          valid = validate_label(object, repo_object) if object.label
          outcome = valid ? PreservationEvent::SUCCESS : PreservationEvent::FAILURE
          create_preservation_event(PreservationEvent::VALIDATION, outcome, outcome_details, repo_object, object)
        end
      else
        valid = false
        detail = "Cannot validate repository object: batch object #{object.id} does not contain pid"
        log.error detail
        outcome_details << detail
        @failures += 1
      end
      valid ? @successes += 1 : @failures += 1
      @details += outcome_details
    end
    
    def validate_label(object, repo_object)
      verifying = "Verifying object label..."
      if repo_object.label.eql?(object.label)
        @validation_details << "#{verifying}#{PASS}"
        return true
      else
        @validation_details << "#{verifying}#{FAIL}"
        return false
      end
    end
    
    def validate_model(object, repo_object)
      verifying = "Verifying object model..."
      begin
        if repo_object.class.eql?(object.model.constantize)
          @validation_details << "#{verifying}#{PASS}"
          return true
        else
          @validation_details << "#{verifying}#{PASS}"
          return false
        end
      rescue
      end
    end
    
    def create_preservation_event(event_type, event_outcome, event_outcome_detail, outcome_details, repository_object, batch_object)
      event_label = case event_type
      when PreservationEvent::INGESTION
        "Object ingestion"
      when PreservationEvent::VALIDATION
        "Object ingest validation"
      end
      event = PreservationEvent.new(:label => event_label,
                                    :event_type => event_type,
                                    :event_date_time => Time.now.utc.strftime(PreservationEvent::DATE_TIME_FORMAT),
                                    :event_detail => event_detail(batch_object),
                                    :event_outcome => event_outcome,
                                    :event_outcome_detail_note => outcome_details.join("\n"),
                                    :linking_object_id_type => PreservationEvent::OBJECT,
                                    :linking_object_id_value => repository_object.internal_uri,
                                    :for_object => repository_object)
      event.save
    end
    
    def event_detail(operation, batch_object)
      PRESERVATION_EVENT_DETAIL % {
        :operation => batch_object.operation,
        :batch_id => batch_object.id,
        :identifier => batch_object.identifier,
        :model => batch_object.model
      }
    end
    
    def add_datastream(repo_object, datastream)
      case datastream[:payload_type]
      when BatchObjectDatastream::PAYLOAD_TYPE_BYTES
        repo_object.datastreams[datastream[:name]].content = datastream[:payload]
      when BatchObjectDatastream::PAYLOAD_TYPE_FILENAME
        datastream_file = File.open(datastream[:payload])
        repo_object.datastreams[datastream[:name]].content_file = datastream_file
        repo_object.save # save the object to the repository before we close the file 
        datastream_file.close
      end
      repo_object.generate_thumbnail! if datastream[:name].eql?(DulHydra::Datastreams::CONTENT)
      return repo_object
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
