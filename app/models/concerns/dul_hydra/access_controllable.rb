module DulHydra
  module AccessControllable
    extend ActiveSupport::Concern

    included do
      # add rightsMetadata datastream with Hydra XML terminology
      has_metadata :name => DulHydra::Datastreams::RIGHTS_METADATA, 
                   :type => Hydra::Datastream::RightsMetadata,
                   :versionable => true, 
                   :label => "Rights Metadata for this object", 
                   :control_group => 'M'
    end

    # adds methods for managing Hydra rightsMetadata content
    include Hydra::AccessControls::Permissions

    def set_initial_permissions(user_creator = nil)
      if user_creator
        self.permissions_attributes = [{type: "user", access: "edit", name: user_creator.to_s}]
      end
    end

  end
end
