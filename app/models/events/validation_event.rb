class ValidationEvent < Event

  include DulHydra::Events::PreservationEventBehavior

  self.preservation_event_type = :val

end
