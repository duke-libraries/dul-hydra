module DulHydra
  class IngestFolderAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      can :create, IngestFolder if IngestFolder.permitted_folders(user).present?
      can [:show, :procezz], IngestFolder, user: user
    end

  end
end
