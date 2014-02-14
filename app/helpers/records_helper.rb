module RecordsHelper
  include RecordsHelperBehavior

  # Override RecordsHelperBehavior
  def record_form_action_url(record)
    record.new_record? ? objects_path(record) : object_path(record)
  end

  def field_name(key)
    "#{resource_instance_name}[#{key}][]"
  end

  def field_id(key)
    "#{resource_instance_name}_#{key}"
  end

end
