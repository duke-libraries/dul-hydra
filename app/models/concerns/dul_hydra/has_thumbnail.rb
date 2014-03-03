module DulHydra
  module HasThumbnail
    extend ActiveSupport::Concern
    extend Deprecation
    
    included do
      has_file_datastream :name => DulHydra::Datastreams::THUMBNAIL, 
                          :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, 
                          :label => "Thumbnail for this object", 
                          :control_group => 'M'

      # Abstract thumbnail setting method
      def set_thumbnail
        raise NotImplementedError
      end
    end

    self.deprecation_horizon = "DulHydra 1.5"

    def thumbnail_changed?
      self.thumbnail.content_changed?
    end

    def copy_thumbnail_from(other)
      if other && other.has_thumbnail?
        self.thumbnail.content = other.thumbnail.content
        self.thumbnail.mimeType = other.thumbnail.mimeType
      end
    end

    def set_thumbnail_from_content
      if has_content?
        transform_datastream :content, { thumbnail: { size: "100x100>", datastream: "thumbnail" } }
      end
    end

    def set_thumbnail!
      set_thumbnail 
      thumbnail_changed? ? save : false
    end

    def generate_content_thumbnail!(args={})
      set_thumbnail_from_content
    end
    deprecation_deprecate :generate_content_thumbnail!

  end  
end
