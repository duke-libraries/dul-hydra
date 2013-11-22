module DulHydra::Services
  class GroupService

    def groups
      default_groups | append_groups
    end

    def user_groups(user)
      default_user_groups(user) | append_user_groups(user)
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
      dg += RoleMapper.role_names
      dg
    end

    def default_user_groups(user)
      dug = [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
      dug << Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED if user.persisted?
      dug += RoleMapper.roles(user)
      dug
    end

  end
end
