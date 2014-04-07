module DulHydra
  module Controller
    module EventLogBehavior
      extend ActiveSupport::Concern

      included do
        require_read_permission! only: :preservation_events
        class_attribute :log_actions
        self.log_actions = [:preservation_events]
        after_action :log_action, if: :log_action?
      end

      # Intended for tab content loaded via ajax
      def preservation_events
        if request.xhr?
          render layout: false
        else
          redirect_to action: "show", tab: "preservation_events"
        end
      end

      module ClassMethods
      end

      protected

      def log_action opts={}
        current_object.log_event log_defaults.merge(opts)
      end

      def no_errors?
        current_object.errors.empty?
      end

      def configured_to_log_action?
        self.class.log_actions.include? params[:action].to_sym
      end
      
      def log_action?
        configured_to_log_action? && request_to_change? && no_errors?
      end

      def request_to_change?
        [:post, :put, :patch, :delete].include? request.request_method_symbol
      end

      private

      def log_defaults
        {action: default_action, comment: params[:comment], user: current_user}
      end

      def default_action
        case params[:action]
        when "permissions"
          EventLog::Actions::MODIFY_RIGHTS
        when "default_permissions"
          EventLog::Actions::MODIFY_POLICY
        when "upload"
          EventLog::Actions::UPLOAD
        when "create"
          EventLog::Actions::CREATE
        when "update"
          EventLog::Actions::UPDATE
        end
      end

    end
  end
end
