module DulHydra::Models
  module HasDigitizationGuide
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::DIGITIZATION_GUIDE, :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
