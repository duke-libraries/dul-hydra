module DulHydra
  module EventLoggable
    extend ActiveSupport::Concern
    extend Deprecation

    def events
      Event.for_object(self)
    end

    def update_events
      UpdateEvent.for_object(self)
    end

    # TESTME
    def notify_event(type, args={})
      DulHydra::Notifications.notify_event(type, args.merge(pid: pid))
    end

    def log_event(type, args={})
      Deprecation.warn(DulHydra::EventLoggable, "The `log_event' method is deprecated and will be removed in version 2.1.0 (final)", caller)
      klass = event_class(type)
      klass.new.tap do |event|
        event.object = self
        event.attributes = args
        event.save!
      end
    end

    def has_events?
      events.count > 0
    end

    private 

    def event_class_name token
      "#{token.to_s.camelize}Event"
    end

    def event_class token
      event_class_name(token).constantize
    end

  end
end
