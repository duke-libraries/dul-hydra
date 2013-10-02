module DulHydra::Batch::Jobs
  class BatchProcessorJob < Struct.new(:batch_id)
    
    def perform
      ts = Time.now.to_i
      logfile = "batch_processor_#{ts}.log"
      bp = DulHydra::Batch::Scripts::BatchProcessor.new(:batch_id => batch_id, :log_file => logfile)
      bp.execute
    end
    
  end
end