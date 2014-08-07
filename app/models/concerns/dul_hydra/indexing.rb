module DulHydra
  module Indexing

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge!(DulHydra::IndexFields::TITLE => title_display,
                      DulHydra::IndexFields::INTERNAL_URI => internal_uri,
                      DulHydra::IndexFields::IDENTIFIER => identifier_sort)
      if respond_to? :fixity_checks
        last_fixity_check = fixity_checks.last
        solr_doc.merge!(last_fixity_check.to_solr) if last_fixity_check
      end
      if respond_to? :virus_checks
        last_virus_check = virus_checks.last
        solr_doc.merge!(last_virus_check.to_solr) if last_virus_check
      end
      if respond_to? :original_filename
        solr_doc.merge!(DulHydra::IndexFields::ORIGINAL_FILENAME => original_filename)
      end
      solr_doc
    end

    def title_display
      return title.first if title.present?
      return identifier.first if identifier.present?
      return original_filename if respond_to?(:original_filename) && original_filename.present?
      "[#{pid}]"
    end

    def identifier_sort
      identifier.first
    end

  end
end
