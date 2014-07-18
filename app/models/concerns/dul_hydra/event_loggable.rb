module DulHydra
  module EventLoggable
    extend ActiveSupport::Concern

    def events
      Event.for_object(self)
    end

    def update_events
      UpdateEvent.for_object(self)
    end

    def log_event(type, args={})
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
