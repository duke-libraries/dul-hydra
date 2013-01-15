module DulHydra::Models
  class Base < ActiveFedora::Base
    include Describable
    include Governable
    include AccessControllable
    include HasPreservationMetadata
    include Reloadable
  end
end
