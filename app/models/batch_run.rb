class BatchRun < ActiveRecord::Base
  attr_accessible :batch, :batch_id, :details, :failure, :outcome, :start, :status, :stop, :success, :total, :version
  belongs_to :batch, :inverse_of => :batch_runs
  
  OUTCOME_SUCCESS = "SUCCESS"
  OUTCOME_FAILURE = "FAILURE"
  
  STATUS_NEW = "NEW"
  STATUS_RUNNING = "RUNNING"
  STATUS_FINISHED = "FINISHED"
  
end
