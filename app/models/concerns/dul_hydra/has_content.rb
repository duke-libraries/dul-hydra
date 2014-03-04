module DulHydra
  module HasContent
    extend ActiveSupport::Concern

    included do
      has_file_datastream name: DulHydra::Datastreams::CONTENT, 
                          type: DulHydra::Datastreams::FileContentDatastream,
                          versionable: true, 
                          label: "Content file for this object", 
                          control_group: 'M'

      include Hydra::Derivatives

      # Original file name of content file should be stored in this property
      has_attributes :original_filename, datastream: DulHydra::Datastreams::PROPERTIES, multiple: false
    end

    def content_type
      self.content.mimeType
    end

    def set_thumbnail
      set_thumbnail_from_content
    end      

    def image?
      content_type =~ /image\//
    end

    def pdf?
      content_type == "application/pdf"
    end
  end
end
