module DulHydra::Models
  class Base < ActiveFedora::Base
    include Hydra::ModelMixins::CommonMetadata # adds rightsMetadata datastream
    include Describable                        # adds descMetadata datastream
    include AccessControllable                 # rightsMetadata management
    include Governable                         # adds governance by admin policy
  end
end
