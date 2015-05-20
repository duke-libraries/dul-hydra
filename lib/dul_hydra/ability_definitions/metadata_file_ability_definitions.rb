module DulHydra
  class MetadataFileAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      if member_of? DulHydra.metadata_file_creators_group
        can :create, MetadataFile
      end
      if authenticated?
        can [:show, :procezz], MetadataFile, user_id: user.id
      end
    end

  end
end
