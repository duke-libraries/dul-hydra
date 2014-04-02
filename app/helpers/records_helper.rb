module RecordsHelper
  include RecordsHelperBehavior

  # override
  def record_form_action_url record
    url_for record
  end

  def field_name(key)
    "#{resource_instance_name}[#{key}][]"
  end

  def field_id(key)
    "#{resource_instance_name}_#{key}"
  end

end
