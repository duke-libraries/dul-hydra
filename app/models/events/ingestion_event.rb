class IngestionEvent < PreservationEvent

  self.preservation_event_type = :ing

  protected

  def default_summary
    "#{object.class.to_s} object ingested" if object_exists?
  end

  def default_event_date_time
    Time.parse(object.create_date) if object_exists?
  end

end
