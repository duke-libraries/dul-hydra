module DulHydra::Models
  module Fooable
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "digitizationguide", :type => DulHydra::Datastreams::FileContentDatastream
      has_file_datastream :name => "fmpexport", :type => DulHydra::Datastreams::FileContentDatastream
    end

  end
end
