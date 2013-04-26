module DulHydra::Scripts
  class BatchProcessor
    
    LOG_CONFIG_FILEPATH = File.join(Rails.root, 'config', 'log4r_batch_processor.yml')
    DEFAULT_LOG_DIR = File.join(Rails.root, 'log')
    DEFAULT_LOG_FILE = "batch_processor.log"
    
    INGEST_PRESERVATION_EVENT_DETAIL = <<-EOS
      Batch ingest
      DulHydra version #{DulHydra::VERSION}
      Identifier: %{identifier}
      Model: %{model}
      %{adminpolicy}
      %{datastreams}
      %{parent}
      %{targetfor}
    EOS

    def initialize(opts={})
      begin
        @batch_id = opts.fetch(:batch_id)
      rescue KeyError
        @log.error "Must specify :batch_id in options; e.g., :batch_id => 2"
      end
      @log_dir = opts.fetch(:log_dir, DEFAULT_LOG_DIR)
      @log_file = opts.fetch(:log_file, DEFAULT_LOG_FILE)
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
      @batch_run.update_attributes(:details => @details.join("\n"),
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
          ingest(object)
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
      begin
        repo_object = object.model.constantize.new
        repo_object.label = object.label if object.label
        repo_object.admin_policy = AdminPolicy.find(object.admin_policy, :cast => true) if object.admin_policy
        object.batch_object_datastreams.each {|d| repo_object = add_datastream(repo_object, d)} if object.batch_object_datastreams
        repo_object.parent = ActiveFedora::Base.find(object.parent, :cast => true) if object.parent
        repo_object.collection = Collection.find(object.target_for, :cast => true) if object.target_for
        repo_object.save
      rescue => e
        @log.error "Attempt to ingest #{object.model} #{object.identifier} FAILED: #{e.message}"
        @failures += 1
      else
        @log.info "Ingested #{object.model} #{object.identifier} into #{repo_object.pid}"
        @details << "Ingested #{object.model} #{object.identifier} into #{repo_object.pid}"
        @successes += 1
        object.update_attributes(:pid => repo_object.pid)
        create_preservation_event(PreservationEvent::INGESTION, PreservationEvent::SUCCESS, repo_object, object)
      end
    end
    
    def validate(object)
      if object.pid
        begin
          repo_object = ActiveFedora::Base.find(object.pid, :cast => true)
          if object.operation.eql? BatchObject::OPERATION_INGEST
            repo_object.class.eql?(object.model.constantize) # must be true to be valid
          end
          
        rescue
        end
      else
        @log.error "Cannot validate repository object: batch object #{object.id} does contain pid"
      end
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
    
    def create_preservation_event(event_type, event_outcome, repository_object, ingest_object)
      event_label = case event_type
      when PreservationEvent::INGESTION
        "Object ingestion"
      when PreservationEvent::VALIDATION
        "Object ingest validation"
      end
      event = PreservationEvent.new(:label => event_label,
                                    :event_type => event_type,
                                    :event_date_time => Time.now.utc.strftime(PreservationEvent::DATE_TIME_FORMAT),
                                    :event_outcome => event_outcome,
                                    :linking_object_id_type => PreservationEvent::OBJECT,
                                    :linking_object_id_value => repository_object.internal_uri,
                                    :event_detail => format_event_details(event_type, ingest_object),
                                    :for_object => repository_object)
      event.save
    end
    
    def format_event_details(event_type, object)
      event_details = case event_type
      when PreservationEvent::INGESTION
        adminpolicy = "Admin policy: #{object.admin_policy}" if object.admin_policy
        if object.batch_object_datastreams
          datastream_list = []
          object.batch_object_datastreams.each { |d| datastream_list << d[:name] }
          datastream_names = "Datastreams: #{datastream_list.join(',')}"
        end
        parent = "Parent: #{object.parent}" if object.parent
        targetfor = "Target for: #{object.target_for}" if object.target_for
        INGEST_PRESERVATION_EVENT_DETAIL % {
          :identifier => object.identifier,
          :model => object.model,
          :adminpolicy => adminpolicy,
          :datastreams => datastream_names,
          :parent => parent,
          :targetfor => targetfor
        }
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
