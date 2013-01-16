module DulHydra::Models
  class Base < ActiveFedora::Base
    include Describable
    include Governable
    include AccessControllable
    include Reloadable
    include FixityCheckable
  end
end
