class BatchRun < ActiveRecord::Base
  attr_accessible :batch, :batch_id, :outcome, :outcome_details, :start, :status, :stop
  belongs_to :batch, :inverse_of => :batch_runs
  
  NEW = "NEW"
  RUNNING = "RUNNING"
  FINISHED = "FINISHED"
  
end
