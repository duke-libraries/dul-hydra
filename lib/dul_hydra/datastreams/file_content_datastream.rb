require 'mime/types'
require 'stringio'

module DulHydra::Datastreams

  class FileContentDatastream < ActiveFedora::Datastream
    
    DEFAULT_MIME_TYPE = "application/octet-stream"
    DEFAULT_FILE_EXTENSION = "bin"
    BUFSIZE = 8192

    def content_file=(file)      
      self.content = file
      self.mimeType = get_mimetype(file)
    end

    # Write datastream content to open file
    def write_content(file)
      StringIO.open(self.content, 'rb') do |strio|
        file.write(strio.read(BUFSIZE)) until strio.eof?
      end
    end

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

    private

    def get_mimetype(file)
      if file.is_a?(ActionDispatch::Http::UploadedFile)
        return file.content_type 
      elsif file.is_a?(File)
        mt = MIME::Types.type_for(file.path)
        return mt[0].to_s unless mt.empty?
      DEFAULT_MIME_TYPE
    end

    end

  end

end
