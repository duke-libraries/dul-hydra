module DulHydra::Models
  module HasMarcXML
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "marcXML", :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
