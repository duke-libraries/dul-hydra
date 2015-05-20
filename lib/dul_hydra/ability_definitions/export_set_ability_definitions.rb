module DulHydra
  class ExportSetAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      if authenticated?
        can :create, ExportSet
        can :manage, ExportSet, user_id: user.id
      end
    end

  end
end
