module DulHydra
  module HasContent
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::CONTENT, 
                          :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, 
                          :label => "Content file for this object", 
                          :control_group => 'M'

      include Hydra::Derivatives
    end

    def content_type
      self.datastreams[DulHydra::Datastreams::CONTENT].mimeType
    end

    def set_thumbnail
      set_thumbnail_from_content
    end
      
  end
end
