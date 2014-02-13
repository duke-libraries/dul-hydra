module RecordsHelper
  include RecordsHelperBehavior

  def record_form_action_url(record)
    record.new_record? ? objects_path(record) : object_path(record)
  end

end
