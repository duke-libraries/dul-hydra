module DulHydra::Models
  module HasJhove
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "jhove", :type => DulHydra::Datastreams::FileContentDatastream
    end
      
  end
end
