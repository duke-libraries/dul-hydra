module ApplicationHelper

  def object_datastream_path(obj, dsid)
    "/#{obj.class.to_s.downcase.pluralize}/#{obj.pid}/datastreams/#{dsid}"
  end

end
