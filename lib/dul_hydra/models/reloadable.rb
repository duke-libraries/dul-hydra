# Backports ActiveFedora::Base#reload
module DulHydra::Models
  module Reloadable

    def reload
      init_with(self.class.find(self.pid).inner_object)
    end
    
  end
end
