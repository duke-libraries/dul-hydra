module DulHydra::Models
  module HasPreservationEvents
    extend ActiveSupport::Concern

    included do
      has_many :preservation_events, 
               :property => :is_preservation_event_for, 
               :inbound => true, 
               :class_name => 'PreservationEvent'
    end

    def validate_checksum(dsID)
      PreservationEvent.validate_checksum(self, dsID)
    end

    def validate_checksum!(dsID)
      PreservationEvent.validate_checksum!(self, dsID)
    end

    def fixity_checks
      # XXX better to get from index?
      preservation_events.select { |e| e.fixity_check? }
    end

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = ActiveFedora::Base.to_solr(solr_doc, opts)
      if fixity_checks.length > 0
        solr_doc.merge!(ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date) => fixity_checks.last.event_date,
                        ActiveFedora::SolrService.solr_name(:last_fixity_check_outcome, :symbol) => fixity_checks.last.event_outcome)
        return solr_doc
      end
    end
      
  end
end
