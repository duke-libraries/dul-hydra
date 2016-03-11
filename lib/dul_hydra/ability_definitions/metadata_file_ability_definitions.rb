module DulHydra
  class MetadataFileAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      can :create, MetadataFile do |mf|
        can? :ingest_metadata, mf.collection_pid
      end
      if authenticated?
        can [:show, :procezz], MetadataFile, user_id: user.id
      end
    end

  end
end
