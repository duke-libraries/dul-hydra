class FixityCheckEvent < Event

  include DulHydra::Events::PreservationEventBehavior
  include DulHydra::Events::ReindexObjectAfterSave

  self.preservation_event_type = :fix
  self.description = "Validation of datastream checksums"

  # Datastream checksum validation outcomes
  VALID = "VALID"
  INVALID = "INVALID"

  DETAIL_PREAMBLE = "Datastream checksum validation results:"
  DETAIL_TEMPLATE = "%{dsid} ... %{validation}"

  # Presists a FixityCheckEvent instance for an ActiveSupport::Notifications::Event
  def self.from_notification_event(event)
    fc_event = from_result(event.payload[:result], event.time)
    fc_event.save
  end

  # Returns a FixityCheckEvent instance for a FixityCheck::Result
  def self.from_result(result, date_time = nil)
    new.tap do |e|
      e.pid = result.pid
      e.event_date_time = date_time || result.checked_at
      e.failure! unless result.success
      detail = [DETAIL_PREAMBLE]
      result.results.each do |dsid, dsProfile|
        validation = dsProfile["dsChecksumValid"] ? VALID : INVALID
        detail << DETAIL_TEMPLATE % {dsid: dsid, validation: validation} 
      end
      e.detail = detail.join("\n")
    end        
  end

  def to_solr
    { DulHydra::IndexFields::LAST_FIXITY_CHECK_ON => event_date_time_s,
      DulHydra::IndexFields::LAST_FIXITY_CHECK_OUTCOME => outcome }
  end

  protected

  def default_software
    Event.repository_software
  end

end
