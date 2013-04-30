module DulHydra::Models
  class Base < ActiveFedora::Base

    include Describable
    include Governable
    include AccessControllable
    include HasPreservationEvents
    include ActiveFedora::Auditable

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge!(self.last_fixity_check_to_solr)
      solr_doc.merge!(DulHydra::IndexFields::TITLE => title_display,
                      DulHydra::IndexFields::INTERNAL_URI => internal_uri)
      solr_doc
    end

    def title_display
      title.first || identifier.first || "[#{pid}]"
    end

    # Validates current version of each datastream
    # Returns a two-valued array consisting of a boolean result
    # and a hash of the datastream profiles.
    # The boolean result is true if and only if all datastream
    # checksums validate.
    def validate_checksums
      outcome = true
      detail = {}
      self.datastreams.each do |dsid, ds|
        next if ds.profile.empty?
        outcome &&= ds.dsChecksumValid
        detail[dsid] = ds.profile
      end
      [outcome, detail]
    end

  end
end
