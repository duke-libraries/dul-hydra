module DulHydra::Batch::Models
  
  class Batch < ActiveRecord::Base
    attr_accessible :description, :name, :user, :details, :failure, :logfile, :outcome, :start, :status, :stop, :success, :total, :version
    belongs_to :user, :inverse_of => :batches
    has_many :batch_objects, :inverse_of => :batch, :dependent => :destroy
#    has_many :batch_runs, :inverse_of => :batch, :dependent => :destroy
    has_attached_file :logfile

    OUTCOME_SUCCESS = "SUCCESS"
    OUTCOME_FAILURE = "FAILURE"
    
    STATUS_RUNNING = "RUNNING"
    STATUS_FINISHED = "FINISHED"
    STATUS_INTERRUPTED = "INTERRUPTED"

    def validate
      errors = []
      batch_objects.each { |object| errors << object.validate }
      errors.flatten
    end
    
  end
  
end