require "resque"

module AbstractJob

  EVENT = "perform_job.dul_hydra".freeze

  def around_perform_instrument(*args)
    ActiveSupport::Notifications.instrument(EVENT,
                                            args: args,
                                            job: self.name,
                                            queue: @queue.to_s
                                           ) do
      yield
    end
  end

end
