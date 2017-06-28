module DulHydra
  class NestedFolderIngestAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      can :create, NestedFolderIngest if can?(:create, Collection)
      can :show, NestedFolderIngest, user: user
    end

  end
end
