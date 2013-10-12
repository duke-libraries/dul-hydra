module DulHydra::Models
  module HasProperties
    extend ActiveSupport::Concern
    
    included do
      has_metadata :name => DulHydra::Datastreams::PROPERTIES, 
                   :type => DulHydra::Datastreams::PropertiesDatastream,
                   :versionable => true, 
                   :label => "Properties for this object", 
                   :control_group => 'X'
      delegate_to DulHydra::Datastreams::PROPERTIES, [:descmetadata_source], multiple: false
    end
    
  end
end