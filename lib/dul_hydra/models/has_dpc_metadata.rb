module DulHydra::Models
  module HasDPCMetadata
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::DPC_METADATA, :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
