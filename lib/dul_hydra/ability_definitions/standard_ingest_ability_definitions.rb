module DulHydra
  class StandardIngestAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      can :create, StandardIngest if can?(:create, Collection)
      can :show, StandardIngest, user: user
    end

  end
end
