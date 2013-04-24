class BatchRun < ActiveRecord::Base
  attr_accessible :batch, :batch_id, :outcome, :outcome_details, :start, :status, :stop
  belongs_to :batch, :inverse_of => :batch_runs
  
  STATUS_NEW = "NEW"
  STATUS_RUNNING = "RUNNING"
  STATUS_FINISHED = "FINISHED"
  
end
