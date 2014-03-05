module DulHydra
  module UploadBehavior

    def upload(obj, opts={})
      file = params.require(:content)
      obj.content.content = file
      obj.content.mimeType = file.content_type
      obj.original_filename = file.original_filename
    end

  end
end
