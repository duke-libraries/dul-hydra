module ApplicationHelper

  def object_datastreams_path(obj)
    send "#{obj.class.to_s.downcase}_datastreams_path".to_sym, obj
  end

  def object_datastream_path(obj, dsid)
    send "#{obj.class.to_s.downcase}_datastream_path".to_sym, obj, dsid
  end

  def object_datastream_content_path(obj, dsid)
    send "#{obj.class.to_s.downcase}_datastream_content_path".to_sym, obj, dsid
  end

end
