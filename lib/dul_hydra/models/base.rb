module DulHydra::Models
  class Base < ActiveFedora::Base

    include Describable
    include Governable
    include AccessControllable
    include HasPreservationEvents
    include Auditable

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge!(last_fixity_check_to_solr)
      solr_doc.merge!(DulHydra::IndexFields::TITLE => title_display)
      solr_doc
    end

    def title_display
      title.first || identifier.first || "[#{pid}]"
    end

  end
end
