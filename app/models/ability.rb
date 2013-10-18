class Ability
  include Hydra::PolicyAwareAbility
  include FcrepoAdmin::Ability
  include DulHydra::Models::Ability
end
