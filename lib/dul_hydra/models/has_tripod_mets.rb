module DulHydra::Models
  module HasTripodMets
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "tripodMets", :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
