module ObjectsHelper

  def descriptive_metadata_edit_link
    link_to "Edit", record_edit_path(current_object)
  end

  def download_datastream_xml_link(dsid)
    link_to "Download XML", download_datastream_object_path(current_object, dsid)
  end

end
