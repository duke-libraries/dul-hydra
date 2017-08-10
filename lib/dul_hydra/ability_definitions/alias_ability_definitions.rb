module DulHydra
  class AliasAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      alias_action :attachments,
                   :duracloud,
                   :captions,
                   :components,
                   :event,
                   :events,
                   :items,
                   :stream,
                   :targets,
                   :versions,
                   to: :read
      alias_action :roles, to: :grant
      alias_action :admin_metadata, to: :update
    end

  end
end
