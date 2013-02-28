module DulHydra::Models
  module HasThumbnail
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::THUMBNAIL, :type => DulHydra::Datastreams::FileContentDatastream
    end
  end
  
end