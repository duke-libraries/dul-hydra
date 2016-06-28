class VersionCreation

  EVENT = Ddr::Models::Base::SAVE_NOTIFICATION

  class << self
    def enable!
      ActiveSupport::Notifications.subscribe(EVENT, self)
    end

    def disable!
      ActiveSupport::Notifications.unsubscribe(self)
    end

    def call(*args)
      event = ActiveSupport::Notifications::Event.new(*args)
      object_id = event.payload[:id]
      enqueue(object_id) unless queued?(object_id)
    end

    def queued?(object_id)
      VersionCreationJob.queued_object_ids.include?(object_id)
    end

    def enqueue(object_id)
      Resque.enqueue(VersionCreationJob, object_id)
    end
  end

end
