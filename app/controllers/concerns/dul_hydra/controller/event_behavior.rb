module DulHydra
  module Controller
    module EventBehavior
      extend ActiveSupport::Concern

      def events
        @events = current_object.events.reorder("event_date_time DESC")
      end

      def event
        @event = Ddr::Events::Event.find(params[:event_id])
      end

      protected

      def notify_event type, args={}
        args[:pid] ||= current_object.pid
        args[:user_id] ||= current_user.id
        args.merge! event_params
        Ddr::Notifications.notify_event(type, args)
      end

      def notify_update args={}
        notify_event :update, args
      end

      def tab_events
        Tab.new("events",
                href: url_for(controller: "events", action: "index", pid: current_object.pid),
                guard: current_object.has_events?)
      end

      def event_params
        params.permit(:comment)
      end

    end
  end
end
