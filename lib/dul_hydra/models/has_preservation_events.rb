module DulHydra::Models
  module HasPreservationEvents
    extend ActiveSupport::Concern

    included do
      has_many :preservation_events, 
               :property => :is_preservation_event_for, 
               :inbound => true, 
               :class_name => 'PreservationEvent'
      before_destroy :delete_preservation_events
    end

    def fixity_checks
      PreservationEvent.events_for(self, PreservationEvent::FIXITY_CHECK)
    end

    def ingestions
      PreservationEvent.events_for(self, PreservationEvent::INGESTION)
    end

    def validations
      PreservationEvent.events_for(self, PreservationEvent::VALIDATION)
    end

    def last_fixity_check_to_solr
      e = self.fixity_checks.to_a.last
      e ? {
        ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date) => e.event_date_time,
        ActiveFedora::SolrService.solr_name(:last_fixity_check_outcome, :symbol) => e.event_outcome
      } : {}
    end

    def fixity_check
      PreservationEvent.fixity_check(self)
    end

    def fixity_check!
      PreservationEvent.fixity_check!(self)
    end

    module ClassMethods
      def find_by_last_fixity_check(before_date=Time.now.utc, limit=100)
        field = ActiveFedora::SolrService.solr_name(:last_fixity_check_on, :date)
        solr_date = before_date.respond_to?(:strftime) ? PreservationEvent.to_event_date_time(before_date) : before_date
        all({:sort => "#{field} asc",
              :rows => limit.to_s,
              :fq => "#{field}:[* TO #{solr_date}]"})
      end
    end

    protected

    def delete_preservation_events
      PreservationEvent.where(ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol) => internal_uri).delete_all
    end

  end
end
