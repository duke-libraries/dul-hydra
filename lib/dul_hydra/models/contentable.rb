require 'mime/types'

module DulHydra::Models
  module Contentable
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "content", :type => ActiveFedora::Datastream
    end

    def add_content(file, mimetype=nil)
      content.content = file
      if mimetype
        content.mimeType = mimetype
      else
        mt = MIME::Types.type_for(file.original_filename)
        content.mimeType = mt.empty? ? "application/octet-stream" : mt[0].to_s
      end
      content.save
    end

  end
end
