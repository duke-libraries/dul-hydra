module DulHydra::Models
  module HasFMPExport
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "fmpExport", :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
