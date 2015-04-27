module DulHydra::Batch::Models

  class Batch < ActiveRecord::Base
    belongs_to :user, :inverse_of => :batches
    has_many :batch_objects, -> { order("id ASC") }, :inverse_of => :batch, :dependent => :destroy
    has_attached_file :logfile
    do_not_validate_attachment_file_type :logfile

    OUTCOME_SUCCESS = "SUCCESS"
    OUTCOME_FAILURE = "FAILURE"

    STATUS_READY = "READY"
    STATUS_VALIDATING = "VALIDATING"
    STATUS_INVALID = "INVALID"
    STATUS_VALIDATED = "VALIDATED"
    STATUS_QUEUED = "QUEUED"
    STATUS_PROCESSING = "PROCESSING"
    STATUS_RUNNING = "RUNNING"
    STATUS_FINISHED = "FINISHED"
    STATUS_INTERRUPTED = "INTERRUPTED"
    STATUS_RESTARTABLE = "INTERRUPTED - RESTARTABLE"

    def validate
      errors = []
      begin
        batch_objects.each do |object|
          unless object.verified
            errors << object.validate
          end
        end
      rescue Exception => e
        errors << "Exception raised during batch validation: #{e}"
      end
      errors.flatten
    end

    def completed_count
      batch_objects.where(verified: true).count
    end

    def time_to_complete
      unless processing_step_start.nil?
        completed = completed_count
        ((Time.now - processing_step_start.to_time) / completed) * (batch_objects.count - completed)
      end
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
