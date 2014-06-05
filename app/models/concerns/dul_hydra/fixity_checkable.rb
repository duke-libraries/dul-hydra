module DulHydra
  module FixityCheckable
   
    def fixity_checks
      FixityCheckEvent.for_object(self)
    end

    # Return a FixityCheckEvent for a fixity check
    def fixity_check
      FixityCheck.execute(self)
    end

    # Persist a FixityCheckEvent for a fixity check
    def fixity_check!
      FixityCheck.execute!(self)
    end
 
  end
end
