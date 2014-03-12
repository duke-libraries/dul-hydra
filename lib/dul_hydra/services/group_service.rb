module DulHydra
  module Services
    class GroupService

      class_attribute :include_role_mapper_groups
      self.include_role_mapper_groups = RoleMapper.role_names.present? rescue false

      def role_mapper_user_groups(user)
        RoleMapper.roles(user) rescue []
      end

      def role_mapper_groups
        RoleMapper.role_names rescue []
      end

      def groups
        default_groups | append_groups
      end

      def user_groups(user)
        default_user_groups(user) | append_user_groups(user)
      end

      def superuser_group
        DulHydra.superuser_group
      end

      def append_groups
        []
      end

      def append_user_groups(user)
        []
      end

      def default_groups
        dg = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC,
              Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED]
        dg += role_mapper_groups if include_role_mapper_groups
        dg
      end

      def default_user_groups(user)
        dug = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
        if user && user.persisted?
          dug << Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
          dug += role_mapper_user_groups(user) if include_role_mapper_groups
        end
        dug
      end

    end
  end
end
