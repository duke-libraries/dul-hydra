module DulHydra
  module HasThumbnail
    extend ActiveSupport::Concern
    
    included do
      has_file_datastream name: DulHydra::Datastreams::THUMBNAIL, 
                          type: DulHydra::Datastreams::FileContentDatastream,
                          versionable: true, 
                          label: "Thumbnail for this object", 
                          control_group: 'M'
    end

    # Abstract thumbnail setting method
    def set_thumbnail
      raise NotImplementedError
    end

    def set_thumbnail!
      set_thumbnail 
      thumbnail_changed? && save
    end

    def thumbnail_changed?
      thumbnail.content_changed?
    end

    def has_thumbnail?
      thumbnail.has_content?
    end

    def copy_thumbnail_from(other)
      if other && other.has_thumbnail?
        self.thumbnail.content = other.thumbnail.content
        self.thumbnail.mimeType = other.thumbnail.mimeType if thumbnail_changed?
      end
      thumbnail_changed?
    end

  end  
end
