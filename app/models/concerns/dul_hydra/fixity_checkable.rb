module DulHydra
  module FixityCheckable
   
    def datastreams_to_validate
      datastreams.select { |dsid, ds| ds.has_content? }
    end

    def fixity_checks
      FixityCheckEvent.for_object(self)
    end

    # Returns a FixityCheck::Result for the object
    def fixity_check
      FixityCheck.execute(self)
    end
 
  end
end
