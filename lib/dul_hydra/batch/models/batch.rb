module DulHydra::Batch::Models
  
  class Batch < ActiveRecord::Base
#    attr_accessible :description, :name, :user, :details, :failure, :logfile, :outcome, :start, :status, :stop, :success, :version
    belongs_to :user, :inverse_of => :batches
    has_many :batch_objects, -> { order("id ASC") }, :inverse_of => :batch, :dependent => :destroy
    has_attached_file :logfile

    OUTCOME_SUCCESS = "SUCCESS"
    OUTCOME_FAILURE = "FAILURE"
    
    STATUS_VALIDATED = "VALIDATED"
    STATUS_QUEUED = "QUEUED"
    STATUS_RUNNING = "RUNNING"
    STATUS_FINISHED = "FINISHED"
    STATUS_INTERRUPTED = "INTERRUPTED"
    STATUS_RESTARTABLE = "INTERRUPTED - RESTARTABLE"

    def validate
      errors = []
      batch_objects.each do |object|
        unless object.verified
          errors << object.validate
        end
      end
      errors.flatten
    end
    
    def found_pids
      @found_pids ||= {}
    end
    
    def add_found_pid(pid, model)
      @found_pids[pid] = model
    end
    
    def pre_assigned_pids
      @pre_assigned_pids ||= collect_pre_assigned_pids
    end
    
    def collect_pre_assigned_pids
      batch_objects.map{ |x| x.pid if x.pid.present? }.compact      
    end
    
    def finished?
      status == STATUS_FINISHED
    end
    
  end
  
end