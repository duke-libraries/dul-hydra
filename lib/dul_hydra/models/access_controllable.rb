module DulHydra::Models
  module AccessControllable
    extend ActiveSupport::Concern

    included do
      # add rightsMetadata datastream with Hydra XML terminology
      has_metadata :name => DulHydra::Datastreams::RIGHTS_METADATA, :type => Hydra::Datastream::RightsMetadata,
                   :versionable => true, :label => "Rights Metadata for this object", :control_group => 'X'
    end

    # adds methods for managing Hydra rightsMetadata content
    include Hydra::AccessControls::Permissions

  end
end
