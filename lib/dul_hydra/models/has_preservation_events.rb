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
      # preservation_events.select { |e| e.fixity_check? }
      PreservationEvent.find({ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol) => internal_uri}, 
                             {:sort => "#{ActiveFedora::SolrService.solr_name(:event_date_time, :date)} asc"})
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

    module ClassMethods
      def find_by_last_fixity_check(before_date=Time.now.utc, limit=100)
        field = ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date)
        solr_date = before_date.respond_to?(:strftime) ? PreservationEvent.to_event_date_time : before_date
        all({:sort => "#{field} asc",
              :rows => limit.to_s,
              :fq => "#{field}:[* TO #{solr_date}]"})
      end
    end

  end
end
