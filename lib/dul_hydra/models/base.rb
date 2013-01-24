module DulHydra::Models
  class Base < ActiveFedora::Base

    include Describable
    include Governable
    include AccessControllable
    include Reloadable
    include HasPreservationEvents

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge!(last_fixity_check_to_solr)
      solr_doc
    end

  end
end
