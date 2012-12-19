module DulHydra::Models
  module HasContentMetadata
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "contentMetadata", :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
