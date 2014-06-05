class VirusCheckEvent < PreservationEvent

  include DulHydra::Events::ReindexObjectAfterSave
  self.preservation_event_type = :vir
  validate :object_is_virus_checkable, if: :object_exists?

  def to_solr
    { DulHydra::IndexFields::LAST_VIRUS_CHECK_ON => event_date_time_s,
      DulHydra::IndexFields::LAST_VIRUS_CHECK_OUTCOME => outcome }
  end

  protected 

  # Validation method
  def object_is_virus_checkable
     unless object_is_virus_checkable?
      errors.add(:pid, "The object \"#{pid}\" cannot have virus check events")
    end
  end

  def object_is_virus_checkable?
    object.respond_to? :virus_checks
  end

  def default_software
    VirusCheck.software
  end

  def default_summary
    "Content file scanned for viruses"
  end

end
