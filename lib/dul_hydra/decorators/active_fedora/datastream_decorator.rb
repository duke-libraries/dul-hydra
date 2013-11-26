require 'mime/types'

ActiveFedora::Datastream.class_eval do

  # Return default file extension for datastream based on MIME type
  def default_file_extension
    mimetypes = MIME::Types[self.mimeType]
    mimetypes.empty? ? DEFAULT_FILE_EXTENSION : mimetypes.first.extensions.first
  end

  # Return default file name prefix based on object PID
  def default_file_prefix
    "#{self.pid.sub(/:/, '_')}_#{self.dsid}"
  end

  # Return default file name
  def default_file_name
    "#{default_file_prefix}.#{default_file_extension}"
  end

end
