module DulHydra::Models
  module HasPreservationEvents
    extend ActiveSupport::Concern

    included do
      has_many :preservation_events, :property => :is_preservation_event_for, :inbound => true, :class_name => 'PreservationEvent'
    end

  end
end
