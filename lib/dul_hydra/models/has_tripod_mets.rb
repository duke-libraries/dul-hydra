module DulHydra::Models
  module HasTripodMets
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::TRIPOD_METS, :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
