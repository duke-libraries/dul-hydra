class FixityCheckEvent < Event

  include DulHydra::Events::PreservationEventBehavior
  include DulHydra::Events::ReindexObjectAfterSave

  self.preservation_event_type = :fix
  self.description = "Validation of datastream checksums"

  def to_solr
    { DulHydra::IndexFields::LAST_FIXITY_CHECK_ON => event_date_time_s,
      DulHydra::IndexFields::LAST_FIXITY_CHECK_OUTCOME => outcome }
  end

  protected

  def default_software
    Event.repository_software
  end

end
