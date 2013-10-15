module DulHydra::Grouper
  module User

    attr_accessor :grouper_groups

    # Overrides Hydra::User#groups, adding Grouper groups
    def groups
      g = super
      g |= grouper_groups if grouper_groups
      g
    end

    # Sets user's Grouper groups from data in the request env.
    def set_grouper_groups(env)
      if env.key?(DulHydra.grouper_groups_env_key)
        # get the raw list of values
        gg = env[DulHydra.grouper_groups_env_key].split(DulHydra.grouper_groups_env_value_delim)
        # munge values to proper Grouper group names, if necessary
        gg = gg.collect { |g| g.sub(*DulHydra.grouper_groups_env_value_sub) } if DulHydra.grouper_groups_env_value_sub
        # filter group list as configured
        gg = gg.select { |g| g =~ DulHydra.grouper_groups_name_filter } if DulHydra.grouper_groups_name_filter
        self.grouper_groups = gg
        logger.debug "Grouper groups for user \"#{self}\" set to: #{self.grouper_groups}"
      else
        logger.debug "Grouper groups env key \"#{DulHydra.grouper_groups_env_key}\" not present."
      end
    end

  end
end
