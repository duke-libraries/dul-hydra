# User model mixin - insert after Hydra::User to override default Hydra behavior
module DulHydra::Grouper
  module User

    # Override Hydra::User
    def groups
      @groups ||= local_groups + grouper_groups
    end

    # This is Hydra::User#groups behavior
    def local_groups
      RoleMapper.roles(self)
    end

    def grouper_groups
      gg = if ability.session && ability.session[:grouper_groups]
             ability.session[:grouper_groups]
           else
             []
           end
      logger.debug "Grouper groups for #{self}: #{gg}"
      gg
    end

  end
end
