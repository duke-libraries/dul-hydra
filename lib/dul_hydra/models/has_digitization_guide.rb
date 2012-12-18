module DulHydra::Models
  module HasDigitizationGuide
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "digitizationGuide", :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
