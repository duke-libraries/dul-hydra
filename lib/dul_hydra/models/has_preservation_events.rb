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
      
  end
end
