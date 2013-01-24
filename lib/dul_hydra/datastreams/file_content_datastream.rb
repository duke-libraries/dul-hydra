require 'mime/types'

module DulHydra::Datastreams

  class FileContentDatastream < ActiveFedora::Datastream
    
    DEFAULT_MIME_TYPE = "application/octet-stream"

    def content_file=(file)      
      self.content = file
      self.mimeType = get_mimetype(file)
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

    end # private

  end

end
