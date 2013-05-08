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
        DulHydra::IndexFields::LAST_FIXITY_CHECK_ON => e.event_date_time,
        DulHydra::IndexFields::LAST_FIXITY_CHECK_OUTCOME => e.event_outcome
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
        field = DulHydra::IndexFields::LAST_FIXITY_CHECK_ON
        solr_date = before_date.respond_to?(:strftime) ? PreservationEvent.to_event_date_time(before_date) : before_date
        all({:sort => "#{field} asc",
              :rows => limit.to_s,
              :fq => "#{field}:[* TO #{solr_date}]"})
      end
    end

    protected

    def delete_preservation_events
      PreservationEvent.where(DulHydra::IndexFields::IS_PRESERVATION_EVENT_FOR => internal_uri).delete_all
    end

  end
end
