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

    def last_fixity_check_to_solr
      fixity_checks.empty? ? {} : {
        ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date) => fixity_checks.last.event_date_time,
        ActiveFedora::SolrService.solr_name(:last_fixity_check_outcome, :symbol) => fixity_checks.last.event_outcome
      }
    end
      
  end
end
