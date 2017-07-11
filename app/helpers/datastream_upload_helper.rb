module DatastreamUploadHelper

  def datastream_upload_checksum_location(datastream_name)
    DatastreamUpload.default_checksum_location(datastream_name)
  end

  def permitted_datastream_upload_bases(datastream_name)
    DatastreamUpload.default_basepaths(datastream_name)
  end

  def datastream_upload_checksum_files(datastream_name)
    Dir.entries(datastream_upload_checksum_location(datastream_name)).select { |e| File.file?(File.join(datastream_upload_checksum_location(datastream_name), e)) }
  end

  def datastream_upload_checksum_files_options_for_select(datastream_name)
    options_for_select(datastream_upload_checksum_files(datastream_name).collect { |f| [ f, f ] }, @datastream_upload.checksum_file)
  end

end
