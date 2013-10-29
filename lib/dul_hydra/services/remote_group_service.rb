module DulHydra::Services
  class RemoteGroupService < GroupService

    attr_reader :env

    def initialize(env = nil)
      @env = env
    end

    def append_groups(user = nil)
      groups = []
      if user
        if env && env.key?(DulHydra.remote_groups_env_key)
          # get the raw list of values
          groups = env[DulHydra.remote_groups_env_key].split(DulHydra.remote_groups_env_value_delim)
          # munge values to proper Grouper group names, if necessary
          groups = groups.collect { |g| g.sub(*DulHydra.remote_groups_env_value_sub) } if DulHydra.remote_groups_env_value_sub
          # filter group list as configured
          groups = groups.select { |g| g =~ /^#{DulHydra.remote_groups_name_filter}/ } if DulHydra.remote_groups_name_filter
        else
          groups = DulHydra::Services::GrouperService.user_group_names(user)
        end
        logger.debug "Remote groups for user \"#{user}\": #{groups}"
      else
        groups = DulHydra::Services::GrouperService.repository_group_names
      end
      groups
    end

  end
end
