module DulHydra::Models
  module HasMarcXML
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::MARCXML, :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, :label => "Aleph MarcXML Data for this object", :control_group => 'M'
    end
      
  end
end
