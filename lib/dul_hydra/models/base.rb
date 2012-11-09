module DulHydra::Models
  class Base < ActiveFedora::Base
    include Describable
    include AccessControllable
    include Governable
  end
end
