module DulHydra
  class RoleManager

    def self.role_names
      RoleMapper.role_names + DulHydra::Grouper::Client.repository_group_names
    end

  end
end
