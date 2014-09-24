class FixityCheckEvent < Event

  include DulHydra::Events::PreservationEventBehavior
  include DulHydra::Events::ReindexObjectAfterSave

  self.preservation_event_type = :fix
  self.description = "Validation of datastream checksums"

  DETAIL_PREAMBLE = "Datastream checksum validation results:"
  DETAIL_TEMPLATE = "%{dsid} ... %{validation}"

  # Message sent by ActiveSupport::Notifications
  def self.call(*args)
    notification = ActiveSupport::Notifications::Event.new(*args)
    result = notification.payload[:result] # FixityCheck::Result instance
    detail = [DETAIL_PREAMBLE]
    result.results.each do |dsid, dsProfile|
      validation = dsProfile["dsChecksumValid"] ? VALID : INVALID
      detail << DETAIL_TEMPLATE % {dsid: dsid, validation: validation} 
    end
    create(pid: result.pid,
           event_date_time: notification.time,
           outcome: result.success ? SUCCESS : FAILURE,
           detail: detail.join("\n")
           )
  end

  def to_solr
    { DulHydra::IndexFields::LAST_FIXITY_CHECK_ON => event_date_time_s,
      DulHydra::IndexFields::LAST_FIXITY_CHECK_OUTCOME => outcome }
  end

  protected

  def default_software
    self.class.repository_software
  end

end
