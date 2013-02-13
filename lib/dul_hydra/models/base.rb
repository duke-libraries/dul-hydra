module DulHydra::Models
  class Base < ActiveFedora::Base

    include Describable
    include Governable
    include AccessControllable
    include HasPreservationEvents

    NO_TITLE = "[No Title]"

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge!(last_fixity_check_to_solr)
      solr_doc.merge!(:title_display => title_display)
      solr_doc
    end

    def title_display
      title.first || NO_TITLE
    end

  end
end
