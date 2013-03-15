module DulHydra::Models
  module HasContentMetadata
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::CONTENT_METADATA, :type => DulHydra::Datastreams::ContentMetadataDatastream
    end
      
  end
end
