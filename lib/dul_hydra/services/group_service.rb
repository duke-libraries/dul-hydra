module DulHydra::Services
  class GroupService

    # Return groups for user (if not nil) or all groups (if nil)
    def groups(user = nil)
      default_groups(user) | append_groups(user)
    end

    def append_groups(user = nil)
      []
    end

    def default_groups(user = nil)
      dg = user ? RoleMapper.roles(user) : RoleMapper.role_names
      # XXX This duplicates logic in Hydra::Ability -- should try to DRY up.
      dg << Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      dg << Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED if user.nil? or user.persisted?
      dg
    end

    def model_creators_group(model)
      model_group(model, "creators")
    end

    def model_editors_group
      model_group(model, "editors")
    end

    def model_group(model, suffix)
      DulHydra.groups.fetch([model.to_s.underscore, suffix].join('_'), nil)
    end

  end
end
