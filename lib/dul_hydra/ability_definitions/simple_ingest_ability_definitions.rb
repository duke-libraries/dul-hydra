module DulHydra
  class SimpleIngestAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      can :create, SimpleIngest if can?(:create, Collection)
      can :show, SimpleIngest, user: user
    end

  end
end
