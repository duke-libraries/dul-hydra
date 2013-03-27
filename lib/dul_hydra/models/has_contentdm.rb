module DulHydra::Models
  module HasContentdm
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::CONTENTDM, :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, :label => "CONTENTdm Data for this object", :control_group => 'M'
    end
      
  end
end
