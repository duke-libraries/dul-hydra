module DulHydra::Models
  module HasContentdm
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::CONTENTDM, :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
