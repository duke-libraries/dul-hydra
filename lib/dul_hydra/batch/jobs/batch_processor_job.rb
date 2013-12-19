module DulHydra::Batch::Jobs
  class BatchProcessorJob < Struct.new(:batch_id)
    
    def perform
      ts = Time.now.to_i
      logfile = "batch_processor_#{ts}.log"
      bp = DulHydra::Batch::Scripts::BatchProcessor.new(:batch_id => batch_id, :log_file => logfile)
      bp.execute
    end
    
    def error(job, exception)
      Rails.logger.error "Delayed Job #{job.id}: #{exception}"
      Rails.logger.error exception.backtrace.join("\n")
    end
    
    def failure(job)
      batch = DulHydra::Batch::Models::Batch.find(batch_id)
      batch.stop = Time.now
      batch.outcome = DulHydra::Batch::Models::Batch::OUTCOME_FAILURE
      batch.status = DulHydra::Batch::Models::Batch::STATUS_INTERRUPTED
      batch.save
      begin
        BatchProcessorRunMailer.send_notification(batch).deliver!
      rescue
        puts "An error occurred while attempting to send the notification."
      end
    end
    
  end
end