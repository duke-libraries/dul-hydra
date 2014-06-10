module DulHydra
  module Events
    module PreservationEventBehavior
      extend ActiveSupport::Concern

      module ClassMethods
        def preservation_event_type
          PreservationEventType.label_for @preservation_event_type
        end

        def has_preservation_event_type preservation_event_type
          @preservation_event_type = preservation_event_type
        end
      end

      def preservation_event_type
        self.class.preservation_event_type
      end

      EVENT_ID_TYPE = "Duke Digital Repository Event ID"

      LINKING_OBJECT_ID_TYPE = "Duke Digital Repository PID"

      def as_premis
        DulHydra::Metadata::PremisEvent.new.tap do |doc|
          doc.event_type = preservation_event_type
          doc.event_id_type = EVENT_ID_TYPE
          doc.event_id_value = id
          doc.event_detail = detail
          doc.linking_object_id_type = LINKING_OBJECT_ID_TYPE
          doc.linking_object_id_value = LINKING_OBJECT_ID_VALUE
          doc.event_outcome = outcome
          doc.event_outcome_detail_note = outcome_detail
          doc.event_date_time = event_date_time_s
        end
      end

      def to_xml
        as_premis.to_xml
      end

    end
  end
end
