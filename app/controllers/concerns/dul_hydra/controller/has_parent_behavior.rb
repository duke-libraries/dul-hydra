module DulHydra
  module Controller
    module HasParentBehavior
      extend ActiveSupport::Concern

      included do
        helper_method :parent
        require_permission! :add_children, only: [:new, :create], object: :parent
        before_action :set_parent, only: :create
        before_action :copy_admin_policy_or_permissions, only: :create
      end

      protected

      def parent
        @parent ||= ActiveFedora::Base.find(params.require(:parent), cast: true)
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
