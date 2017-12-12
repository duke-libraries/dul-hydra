module DulHydra
  class AliasAbilityDefinitions < Ddr::Auth::AbilityDefinitions

    def call
      alias_action :attachments,
                   :duracloud,
                   :captions,
                   :collection_info,
                   :components,
                   :event,
                   :events,
                   :files,
                   :intermediate,
                   :items,
                   :stream,
                   :targets,
                   to: :read
      alias_action :roles, to: :grant
      alias_action :admin_metadata,
                   :generate_structure,
                   to: :update
    end

  end
end
