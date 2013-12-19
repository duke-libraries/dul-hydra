module DulHydra::Batch::Models
  
  class IngestBatchObject < DulHydra::Batch::Models::BatchObject
  
    def local_validations
      errors = []
      errors << "#{@error_prefix} Model required for INGEST operation" unless model
      errors += validate_pre_assigned_pid if pid
      errors
    end
  
    def validate_pre_assigned_pid
      errs = []
      errs << "#{@error_prefix} #{pid} already exists in repository" if ActiveFedora::Base.exists?(pid)
      return errs      
    end
    
    def model_datastream_keys
      model.constantize.new.datastreams.keys
    end
        
    def process(opts = {})
      ingest(opts) unless verified
    end
    
    def results_message
      if pid
        verification_result = (verified ? "Verified" : "VERIFICATION FAILURE")
        message = "Ingested #{model} #{identifier} into #{pid}...#{verification_result}"
      else
        message = "Attempt to ingest #{model} #{identifier} FAILED"
      end      
    end
        
    private
    
    def ingest(opts = {})
      repo_object = create_repository_object
      if !repo_object.nil?
        ingest_outcome_detail = []
        ingest_outcome_detail << "Ingested #{model} #{identifier} into #{repo_object.pid}"
        create_preservation_event(PreservationEvent::INGESTION,
                                  PreservationEvent::SUCCESS,
                                  ingest_outcome_detail,
                                  repo_object)
        update_attributes(:pid => repo_object.pid)
        verifications = verify_repository_object
        verification_outcome_detail = []
        verified = true
        verifications.each do |key, value|
          verification_outcome_detail << "#{key}...#{value}"
          verified = false if value.eql?(VERIFICATION_FAIL)
        end
        update_attributes(:verified => verified)
        create_preservation_event(PreservationEvent::VALIDATION,
                                  verified ? PreservationEvent::SUCCESS : PreservationEvent::FAILURE,
                                  verification_outcome_detail,
                                  repo_object)
      else
        verifications = nil
      end
      repo_object
    end
    
    def create_repository_object
      repo_pid = pid if pid.present?
      repo_object = model.constantize.new(:pid => repo_pid)
      repo_object.label = label if label
      repo_object.save
      batch_object_datastreams.each {|d| repo_object = populate_datastream(repo_object, d)} if batch_object_datastreams
      batch_object_relationships.each {|r| repo_object = add_relationship(repo_object, r)} if batch_object_relationships
      repo_object.save
      repo_object
    end  
  
    def create_preservation_event(event_type, event_outcome, outcome_details, repository_object)
      event = PreservationEvent.new(:event_type => event_type,
                                    :event_detail => event_detail(event_type),
                                    :event_outcome => event_outcome,
                                    :event_outcome_detail_note => outcome_details.join("\n"),
                                    )
      event.for_object = repository_object
      event.save
    end
    
    def event_detail(event_type)
      event_label = case event_type
              when PreservationEvent::INGESTION
                "Object ingestion"
              when PreservationEvent::VALIDATION
                "Object ingest validation"
              end
      PRESERVATION_EVENT_DETAIL % {
        :label => event_label,
        :batch_id => id,
        :identifier => identifier,
        :model => model
      }
    end
  
  end

end