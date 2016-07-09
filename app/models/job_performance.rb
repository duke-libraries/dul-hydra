class JobPerformance < ActiveRecord::Base

  serialize :exception, JSON
  serialize :args, JSON

  class << self
    attr_accessor :events

    def enable!
      ActiveSupport::Notifications.subscribe(events, self)
    end

    def disable!
      ActiveSupport::Notifications.unsubscribe(self)
    end

    def call(*args)
      event = ActiveSupport::Notifications::Event.new(*args)
      job, queue = event.name.split(".")[0..1]
      create(job: event.payload[:job],
             args: event.payload[:args],
             queue: event.payload[:queue],
             started: event.time,
             finished: event.end,
             duration: event.duration,
             exception: event.payload[:exception],
             success: event.payload[:exception].nil?
            )
    end
  end

  self.events = AbstractJob::EVENT

end
