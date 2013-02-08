module ApplicationHelper

  def object_datastreams_path(obj)
    send "#{object_path_prefix(obj)}_datastreams_path".to_sym, obj
  end

  def object_datastream_path(obj, dsid)
    send "#{object_path_prefix(obj)}_datastream_path".to_sym, obj, dsid
  end

  def object_path_prefix(obj)
    obj.class.to_s.downcase
  end

end
