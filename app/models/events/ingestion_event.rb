class IngestionEvent < Event

  include DulHydra::Events::PreservationEventBehavior

  self.preservation_event_type = :ing
  self.description = "Object ingested into the repository"

end
