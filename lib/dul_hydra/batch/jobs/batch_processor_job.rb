module DulHydra::Batch::Jobs
  class BatchProcessorJob < Struct.new(:batch_id)
    
    def perform
      ts = Time.now.to_i
      logfile = "batch_processor_#{ts}.log"
      bp = DulHydra::Batch::Scripts::BatchProcessor.new(:batch_id => batch_id, :log_file => logfile)
      bp.execute
    end
    
    def failure(job)
      batch = DulHydra::Batch::Models::Batch.find(batch_id)
      batch_run = batch.batch_runs.last
      batch_run.stop = Time.now
      batch_run.outcome = DulHydra::Batch::Models::BatchRun::OUTCOME_FAILURE
      batch_run.status = DulHydra::Batch::Models::BatchRun::STATUS_INTERRUPTED
      batch_run.save
    end
    
  end
end