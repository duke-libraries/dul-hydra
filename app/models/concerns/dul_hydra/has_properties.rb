module DulHydra
  module HasProperties
    extend ActiveSupport::Concern
    
    included do
      has_metadata :name => DulHydra::Datastreams::PROPERTIES, 
                   :type => DulHydra::Datastreams::PropertiesDatastream,
                   :versionable => true, 
                   :label => "Properties for this object", 
                   :control_group => 'X'
      has_attributes :descmetadata_source, datastream: DulHydra::Datastreams::PROPERTIES, multiple: false
    end
    
  end
end
