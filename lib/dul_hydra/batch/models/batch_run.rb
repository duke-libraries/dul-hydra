module DulHydra::Batch::Models
  
  class BatchRun < ActiveRecord::Base
    attr_accessible :batch, :batch_id, :details, :failure, :logfile, :outcome, :start, :status, :stop, :success, :total, :version
    belongs_to :batch, :inverse_of => :batch_runs
    has_attached_file :logfile
    
    OUTCOME_SUCCESS = "SUCCESS"
    OUTCOME_FAILURE = "FAILURE"
    
    STATUS_RUNNING = "RUNNING"
    STATUS_FINISHED = "FINISHED"
    STATUS_INTERRUPTED = "INTERRUPTED"
  end

end