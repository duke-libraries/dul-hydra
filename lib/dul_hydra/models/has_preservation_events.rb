module DulHydra::Models
  module HasPreservationEvents
    extend ActiveSupport::Concern

    included do
      before_destroy :delete_preservation_events
    end

    def preservation_events
      PreservationEvent.events_for(self)
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
      e = self.fixity_checks.last
      e ? {
        DulHydra::IndexFields::LAST_FIXITY_CHECK_ON => PreservationEvent.to_event_date_time(e.event_date_time),
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
      self.preservation_events.delete_all
    end

  end
end
