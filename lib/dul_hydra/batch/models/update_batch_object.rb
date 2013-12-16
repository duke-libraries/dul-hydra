module DulHydra::Batch::Models
  
  class UpdateBatchObject < DulHydra::Batch::Models::BatchObject
  
    def local_validations
      errs = []
      errs << "#{@error_prefix} PID required for UPDATE operation" unless pid
      if pid
        if ActiveFedora::Base.exists?(pid)
          errs << "#{@error_prefix} #{batch.user.user_key} not permitted to edit #{pid}" unless batch.user.can?(:edit, ActiveFedora::Base.find(pid, :cast => true))
        else
          errs << "#{@error_prefix} PID #{pid} not found in repository" unless ActiveFedora::Base.exists?(pid)
        end
      end
      errs
    end
  
    def model_datastream_keys
      if pid
        begin
          obj = ActiveFedora::Base.find(pid, :cast => true)
          obj.datastreams.keys
        rescue
          nil
        end
      end
    end
        
    def process(opts = {})
      repo_object = update_repository_object(opts)
      verifications = verify_repository_object
      verification_outcome_detail = []
      verified = true
      verifications.each do |key, value|
        verification_outcome_detail << "#{key}...#{value}"
        verified = false if value.eql?(VERIFICATION_FAIL)
      end
      update_attributes(:verified => verified)
      Results.new(repo_object, verified, verifications)
    end
    
    def results_message
      if pid
        verification_result = (verified ? "Verified" : "VERIFICATION FAILURE")
        message = "Updated #{pid}...#{verification_result}"
      else
        message = "Attempt to update #{model} #{identifier} FAILED"
      end      
    end
        
    private
    
    def update_repository_object(opts = {})
      repo_object = ActiveFedora::Base.find(pid, :cast => true)
      if batch_object_datastreams
        batch_object_datastreams.each do |d|
          repo_object = case
          when d.operation.eql?(DulHydra::Batch::Models::BatchObjectDatastream::OPERATION_ADDUPDATE)
            populate_datastream(repo_object, d)
          end        
        end
      end
      repo_object.save
      repo_object
    end

  end
end