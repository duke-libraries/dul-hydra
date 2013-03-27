module DulHydra::Models
  module HasFMPExport
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::FMP_EXPORT, :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, :label => "FileMakerPro Export Data for this object", :control_group => 'M'
    end
      
  end
end
