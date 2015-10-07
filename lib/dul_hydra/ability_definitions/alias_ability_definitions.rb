module DulHydra
  class AliasAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      alias_action :attachments, :components, :event, :events, :items, :targets, :versions,
                   to: :read
      alias_action :roles, to: :grant
      alias_action :admin_metadata, to: :update
      alias_action :report, to: :audit
    end

  end
end
