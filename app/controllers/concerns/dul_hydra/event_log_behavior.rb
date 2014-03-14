module DulHydra
  module EventLogBehavior
    extend ActiveSupport::Concern

    module ClassMethods
      def log_actions *actions
        after_action :log_action, only: actions
      end
    end

    protected

    def log_action opts={}
      obj = opts.delete(:object) || get_resource_ivar
      raise DulHydra::Error, "Object to record an event log is missing" unless obj
      return if obj.errors.any?
      defaults = {
        action: params[:action], 
        comment: params[:comment], 
        user: current_user
      }
      obj.log_event(defaults.merge(opts))
    end    

  end
end
