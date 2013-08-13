module DulHydra::Batch::Jobs
  class BatchProcessorJob < Struct.new(:batch_id)
    def perform
      bp = DulHydra::Batch::Scripts::BatchProcessor.new(:batch_id => batch_id)
      bp.execute
    end
  end
end