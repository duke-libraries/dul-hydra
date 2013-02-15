module ApplicationHelper

  def uri_to_pid(uri)
    uri.split('/').last
  end

end
