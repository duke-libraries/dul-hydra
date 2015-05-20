module DulHydra
  module Controller
    module HasParentBehavior
      extend ActiveSupport::Concern

      included do
        delegate :parent, to: :current_object
        helper_method :parent
        before_action :copy_admin_policy_or_roles_from_parent, only: :create
      end

      protected

      def after_load_before_authorize
        current_object.parent_id = params.require(:parent_id)
      end

      def copy_admin_policy_or_roles_from_parent
        current_object.copy_admin_policy_or_roles_from(parent)
      end

    end
  end
end
