module DulHydra
  module Services
    class RemoteGroupService < GroupService

      attr_reader :env

      def initialize(env = nil)
        @env = env
      end

      def append_groups
        GrouperService.repository_group_names
      end

      def append_user_groups(user)
        if env && env.key?(DulHydra.remote_groups_env_key)
          remote_groups
        else
          GrouperService.user_group_names(user)
        end
      end

      def remote_groups
        # get the raw list of values
        groups = env[DulHydra.remote_groups_env_key].split(DulHydra.remote_groups_env_value_delim)
        # munge values to proper Grouper group names, if necessary
        groups = groups.collect { |g| g.sub(*DulHydra.remote_groups_env_value_sub) } if DulHydra.remote_groups_env_value_sub
        # filter group list as configured
        groups = groups.select { |g| g =~ /^#{DulHydra.remote_groups_name_filter}/ } if DulHydra.remote_groups_name_filter
        groups
      end

    end
  end
end
