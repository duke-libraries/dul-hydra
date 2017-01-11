require "resque"

module AbstractJob

  def send_email(email:, subject:, message:)
    JobMailer.basic(to: email,
                    subject: subject,
                    message: message).deliver
  end

  # @return [Array<String>] list of object ids queued for this job type.
  # @note Assumes that the object_id is the first argument of the .perform method.
  def queued_object_ids(args={})
    args[:type] = self
    job_queue.jobs(args).map { |job| job["args"].first }
  end

  def job_queue
    @job_queue ||= JobQueue.new(queue_name)
  end

  def queue_name
    @queue || Resque.queue_from_class(self)
  end

end
