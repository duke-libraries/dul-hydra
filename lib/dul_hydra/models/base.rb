module DulHydra::Models
  class Base < ActiveFedora::Base
    include Hydra::ModelMixins::CommonMetadata
    include Describable
    include Governable
  end
end
