module DulHydra::Models
  module AccessControllable
    extend ActiveSupport::Concern

    included do
      # add rightsMetadata datastream with Hydra XML terminology
      has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata
    end

    # adds methods for managing Hydra rightsMetadata content
    include Hydra::ModelMixins::RightsMetadata

    include Permissible

  end # module
end # module
