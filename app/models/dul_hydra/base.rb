module DulHydra
  class Base < ActiveFedora::Base

    include Describable
    include Governable
    include AccessControllable
    include Licensable
    include HasPreservationEvents
    include HasProperties
    include HasThumbnail
    include ActiveFedora::Auditable
    include EventLoggable

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

    # Validates current version of each datastream that has content.
    # Returns a two-valued array consisting of a boolean result
    # and a hash of the datastream profiles.
    # The boolean result is true if and only if all datastream
    # checksums validate.
    def validate_checksums
      outcome = true
      results = {}
      self.datastreams.select { |dsid, ds| ds.has_content? }.each do |dsid, ds|
        outcome &&= ds.dsChecksumValid
        results[dsid] = ds.profile
      end
      [outcome, results]
    end

    def copy_admin_policy_or_permissions_from(other)
      copy_permissions_from(other) unless copy_admin_policy_from(other)
    end

    def association_query(association)
      # XXX Ideally we would include a clause to limit by AF model, but this should suffice
      ActiveFedora::SolrService.construct_query_for_rel(reflections[association].options[:property] => internal_uri)
    end

  end
end
