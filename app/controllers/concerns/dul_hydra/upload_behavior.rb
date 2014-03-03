module DulHydra
  module UploadBehavior

    def upload(obj, opts={})
      file = params.require(:content)
      obj.content.content = file
      obj.content.mimeType = file.content_type
      obj.source = file.original_filename
      obj.set_thumbnail if opts[:thumbnail]
    end

  end
end
