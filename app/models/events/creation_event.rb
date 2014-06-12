class CreationEvent < Event

  include DulHydra::Events::PreservationEventBehavior

  self.preservation_event_type = :cre
  self.description = "Object created in the repository"

end
