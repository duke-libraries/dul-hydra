module DulHydra
  module HasContent
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::CONTENT, 
                          :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, 
                          :label => "Content file for this object", 
                          :control_group => 'M'
    end
      
  end
end
