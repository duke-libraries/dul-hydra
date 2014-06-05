class UpdateEvent < Event 

  protected

  def default_event_date_time
    Time.parse(object.modified_date) if object_exists?
  end

end
