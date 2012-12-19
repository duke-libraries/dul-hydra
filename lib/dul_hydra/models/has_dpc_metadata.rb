module DulHydra::Models
  module HasDPCMetadata
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "dpcMetadata", :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
