# User model mixin - include after Hydra::User to override Hydra #groups behavior
# Requires adding DulHydra::Grouper::Ability mixin to Ability class.
module DulHydra::Grouper
  module User

    def groups
      super + grouper_groups
    end

    def grouper_groups
      
    end

  end
end
