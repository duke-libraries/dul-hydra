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
    __queue__.jobs(args).map { |job| job["args"].first }
  end

  protected

  def method_missing(name, *args, &block)
    if name == :queue
      # If .queue method not defined, do the right thing
      Resque.queue_from_class(self)
    else
      super
    end
  end

  private

  def __queue__
    Queue.new(queue)
  end

end
