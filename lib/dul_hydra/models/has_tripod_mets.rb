module DulHydra::Models
  module HasTripodMets
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::TRIPOD_METS, :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, :label => "Tripod METS Data for this object", :control_group => 'M'
    end
      
  end
end
