module DulHydra
  module HasContentMetadata
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::CONTENT_METADATA, 
                          :type => DulHydra::Datastreams::ContentMetadataDatastream,
                          :versionable => true, 
                          :label => "Structural Content Data for this object", 
                          :control_group => 'M'
    end
      
  end
end
