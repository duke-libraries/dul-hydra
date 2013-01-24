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
      preservation_events.select { |e| e.fixity_check? }
    end

    def last_fixity_check
      fixity_checks.empty? ? nil : fixity_checks.sort_by { |e| e.event_date_time }.last
    end

    def last_fixity_check_to_solr
      e = last_fixity_check
      e ? {
        ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date) => e.event_date_time,
        ActiveFedora::SolrService.solr_name(:last_fixity_check_outcome, :symbol) => e.event_outcome
      } : {}
    end

  end
end
