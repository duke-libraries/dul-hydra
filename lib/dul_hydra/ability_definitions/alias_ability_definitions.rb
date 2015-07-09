module DulHydra
  class AliasAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      alias_action :attachments, :collection_info, :components, :event, :events, :items, :targets, to: :read
      alias_action :roles, to: :grant
      alias_action :admin_metadata, to: :update
    end

  end
end
