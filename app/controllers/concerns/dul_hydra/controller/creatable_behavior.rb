module DulHydra
  module Controller
    module CreatableBehavior
      extend ActiveSupport::Concern

      def new
      end

      def create
        set_initial_permissions
        if current_object.save
          notify_creation
          flash[:success] = after_create_success_message
          after_create_success
          redirect_to after_create_redirect
        else
          render :new
        end
      end

      protected

      def after_create_success
        # no-op -- override to add behavior after save and before redirect
      end

      def notify_creation
        notify_event :creation
      end

      def after_create_success_message
        "New #{current_object.class.to_s} created."
      end

      def after_create_redirect
        {action: :edit, id: current_object}
      end

      def set_initial_permissions
        current_object.set_initial_permissions current_user
      end

    end
  end
end
