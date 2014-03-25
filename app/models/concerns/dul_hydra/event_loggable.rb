module DulHydra
  module EventLoggable
    extend ActiveSupport::Concern

    included do
      def self.event_logs(conditions = {})
        EventLog.where(conditions.merge(model: to_s))
      end
    end

    def log_event(args)
      EventLog.create_for_model_action(args.merge(object: self))
    end

    def event_logs(conditions = {})
      EventLog.where(conditions.merge(object_identifier: self.pid))
    end

  end
end
