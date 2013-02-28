module DulHydra::Models
  module HasFMPExport
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::FMP_EXPORT, :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
