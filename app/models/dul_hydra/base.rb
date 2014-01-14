module DulHydra
  class Base < ActiveFedora::Base

    include Describable
    include Governable
    include AccessControllable
    include Licensable
    include HasAttachments
    include HasPreservationEvents
    include HasProperties
    include HasThumbnail
    include ActiveFedora::Auditable

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge!(self.last_fixity_check_to_solr)
      solr_doc.merge!(DulHydra::IndexFields::TITLE => title_display,
                      DulHydra::IndexFields::INTERNAL_URI => internal_uri,
                      DulHydra::IndexFields::IDENTIFIER => identifier_sort)
      solr_doc
    end

    def title_display
      title.first || identifier.first || "[#{pid}]"
    end

    def identifier_sort
      identifier.first
    end

    # Validates current version of each datastream
    # Returns a two-valued array consisting of a boolean result
    # and a hash of the datastream profiles.
    # The boolean result is true if and only if all datastream
    # checksums validate.
    def validate_checksums
      outcome = true
      results = {}
      self.datastreams.each do |dsid, ds|
        next if ds.profile.empty?
        outcome &&= ds.dsChecksumValid
        results[dsid] = ds.profile
      end
      [outcome, results]
    end

  end
end
