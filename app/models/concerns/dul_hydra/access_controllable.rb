module DulHydra
  module AccessControllable
    extend ActiveSupport::Concern

    # adds methods for managing Hydra rightsMetadata content
    include Hydra::AccessControls::Permissions

    def set_initial_permissions(user_creator = nil)
      if user_creator
        self.permissions_attributes = [{type: "user", access: "edit", name: user_creator.to_s}]
      end
    end

  end
end
