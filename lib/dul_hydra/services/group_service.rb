module DulHydra::Services
  class GroupService

    def groups(user = nil)
      default_groups(user) | append_groups(user)
    end

    protected

    def append_groups(user = nil)
      []
    end

    private

    def default_groups(user = nil)
      user ? RoleMapper.roles(user) : RoleMapper.role_names
    end

  end
end
