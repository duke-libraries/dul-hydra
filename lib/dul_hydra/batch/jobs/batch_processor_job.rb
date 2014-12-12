module DulHydra::Batch::Jobs
  class BatchProcessorJob
    @queue = :batch
    
    def self.perform(batch_id, operator_id)
      ts = Time.now.to_i
      logfile = "batch_processor_#{ts}_log.txt"
      batch = DulHydra::Batch::Models::Batch.find(batch_id)
      operator = User.find(operator_id)
      bp = DulHydra::Batch::Scripts::BatchProcessor.new(batch, operator, log_file: logfile)
      bp.execute
    end
    
    def self.after_enqueue_set_status(batch_id, operator_id)
      batch = DulHydra::Batch::Models::Batch.find(batch_id)
      batch.status = DulHydra::Batch::Models::Batch::STATUS_QUEUED
      batch.save      
    end
    
  end
end