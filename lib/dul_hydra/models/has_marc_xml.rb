module DulHydra::Models
  module HasMarcXML
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::MARCXML, :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
