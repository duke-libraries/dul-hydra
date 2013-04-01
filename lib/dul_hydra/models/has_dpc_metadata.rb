module DulHydra::Models
  module HasDPCMetadata
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::DPC_METADATA, :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, :label => "DPC Metadata Data for this object", :control_group => 'M'
    end
      
  end
end
