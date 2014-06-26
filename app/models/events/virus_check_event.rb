class VirusCheckEvent < Event

  include DulHydra::Events::PreservationEventBehavior
  include DulHydra::Events::ReindexObjectAfterSave

  self.preservation_event_type = :vir
  self.description = "Content file scanned for viruses"

  def to_solr
    { DulHydra::IndexFields::LAST_VIRUS_CHECK_ON => event_date_time_s,
      DulHydra::IndexFields::LAST_VIRUS_CHECK_OUTCOME => outcome }
  end

end
