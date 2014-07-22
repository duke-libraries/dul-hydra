module DulHydra
  module Controller
    module EventBehavior
      extend ActiveSupport::Concern

      included do
        class_attribute :log_actions
        self.log_actions = []
        after_action :log_action, if: :log_action?
      end

      def events
      end

      def event
        @event = Event.find(params[:event_id])
      end

      protected

      def log_action
        event_options = default_event_options.merge event_options_for_action
        current_object.log_event event_type, event_options
      end

      def no_errors?
        current_object.errors.empty?
      end
      
      def log_action?
        configured_to_log_action? && request_to_change? && no_errors?
      end

      def configured_to_log_action?
        self.class.log_actions.include? params[:action].to_sym
      end 

      def request_to_change?
        [:post, :put, :patch, :delete].include? request.request_method_symbol
      end

      def tab_events
        Tab.new("events", 
                href: url_for(controller: "events", action: "index", pid: current_object.pid),
                guard: current_object.has_events?)
      end

      def event_type
        params[:action] == "create" ? :creation : :update
      end

      def event_params
        params.permit(:comment)
      end

      def default_event_options
        options = {user: current_user}
        options.merge event_params
      end

      def event_options_for_action
        case params[:action]
        when "update"
          {summary: "Descriptive metadata updated"}
        else
          {}
        end
      end

    end
  end
end
