class Ability
  include Hydra::Ability
  include Hydra::PolicyAwareAbility
  include FcrepoAdmin::Ability

  def custom_permissions
    alias_action :preservation_events, :to => :read
  end

end
