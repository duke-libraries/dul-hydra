module DulHydra::Models
  module HasContent
    extend ActiveSupport::Concern

    include HasPreservationEvents
    include FixityCheckable

    included do
      has_file_datastream :name => "content", :type => DulHydra::Datastreams::FileContentDatastream
    end

    def validate_content_checksum
      self.validate_ds_checksum(self.datastreams["content"])
    end

    def validate_content_checksum!
      self.validate_ds_checksum!(self.datastreams["content"])
    end
      
  end
end
