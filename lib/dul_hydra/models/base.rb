module DulHydra::Models
  class Base < ActiveFedora::Base
    include Describable
    include Governable
    include AccessControllable
    include Reloadable
  end
end
