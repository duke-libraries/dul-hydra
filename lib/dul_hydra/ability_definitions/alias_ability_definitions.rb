module DulHydra
  class AliasAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      alias_action :attachments, :components, :event, :events, :items, :targets, :versions, :duracloud,
                   to: :read
      alias_action :roles, to: :grant
      alias_action :admin_metadata, to: :update
    end

  end
end
