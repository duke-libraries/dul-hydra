class FixityCheckEvent < PreservationEvent

  include DulHydra::Events::ReindexObjectAfterSave
  self.preservation_event_type = :fix
  validate :object_is_fixity_checkable, if: :object_exists?

  def to_solr
    { DulHydra::IndexFields::LAST_FIXITY_CHECK_ON => event_date_time_s,
      DulHydra::IndexFields::LAST_FIXITY_CHECK_OUTCOME => outcome }
  end

  protected

  # Validation method
  def object_is_fixity_checkable
    unless object_is_fixity_checkable?
      errors.add(:pid, "The object \"#{pid}\" cannot have fixity check events")
    end
  end

  def object_is_fixity_checkable?
    object.respond_to? :fixity_checks
  end

  def default_software
    repository_software
  end

  def default_summary
    "Validation of datastream checksums"
  end

end
