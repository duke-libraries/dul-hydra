module DulHydra
  class RoleManager

    def self.list_roles
      RoleMapper.role_names + DulHydra::Grouper::Client.repository_group_names
    end

    def self.roles_for(user)
      user.groups # XXX Let's not do that
    end

  end
end
