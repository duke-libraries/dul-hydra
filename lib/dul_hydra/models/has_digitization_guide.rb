module DulHydra::Models
  module HasDigitizationGuide
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::DIGITIZATION_GUIDE, :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, :label => "Digitization Guide Data for this object", :control_group => 'M'
    end
      
  end
end
