module DulHydra
  module Controller
    module CreatableBehavior
      extend ActiveSupport::Concern

      included do
        self.log_actions << :create
        before_action :auto_title, only: :create
        before_action :set_initial_permissions, only: :create
      end

      def new
      end

      def create
        if current_object.save
          flash[:success] = "New #{current_object.class.to_s} created."
          redirect_to after_create_redirect
        else
          render :new
        end
      end

      protected

      def after_create_redirect
        {action: :edit, id: current_object}
      end

      def set_initial_permissions
        current_object.set_initial_permissions current_user
      end

      def create_params
        {pid: ActiveFedora::Base.connection_for_pid('0').mint}
      end

      def auto_title
        if current_object.required?(:title) && current_object.title.blank?
          if current_object.respond_to? :auto_title
            current_object.auto_title
          else
            current_object.title = Array("New #{current_object.class.to_s} #{current_object.pid}")
          end
        end
      end

    end
  end
end
