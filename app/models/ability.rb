class Ability
  include Hydra::Ability
  include Hydra::PolicyAwareAbility
  include FcrepoAdmin::Ability

  def custom_permissions
    export_sets_permissions
  end

  def export_sets_permissions
    can :manage, ExportSet, :user_id => @current_user.id
  end

end
