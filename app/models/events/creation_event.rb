class CreationEvent < PreservationEvent

  self.preservation_event_type = :cre

  protected 
  
  def default_summary
    "#{object.class.to_s} object created" if object_exists?
  end

  def default_event_date_time
    Time.parse(object.create_date) if object_exists?
  end

end
