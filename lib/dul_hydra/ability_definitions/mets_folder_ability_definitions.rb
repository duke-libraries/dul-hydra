module DulHydra
  class METSFolderAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      can :create, METSFolder do |mf|
        can? :edit, Collection.find(mf.collection_id)
      end
      can [:show, :procezz], METSFolder, user: user
    end

  end
end
