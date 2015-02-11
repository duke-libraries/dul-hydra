module DulHydra
  module Controller
    module HasParentBehavior
      extend ActiveSupport::Concern

      included do
        helper_method :parent

        skip_authorize_resource only: [:new, :create]
        before_action :find_parent, only: [:new, :create]
        before_action :authorize_add_children!, only: [:new, :create]
        before_action :set_parent, only: :create
        before_action :copy_admin_policy_or_permissions, only: :create
      end

      protected

      def authorize_add_children!
        authorize! :add_children, parent
      end

      def parent
        @parent ||= current_object.parent
      end

      def find_parent
        @parent = ActiveFedora::Base.find(parent_param)
      end

      def parent_param
        params.require(:parent_id)
      end

      def set_parent
        current_object.parent = parent
      end

      def copy_admin_policy_or_permissions
        current_object.copy_admin_policy_or_permissions_from parent
      end

    end
  end
end
