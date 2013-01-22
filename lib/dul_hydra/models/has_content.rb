module DulHydra::Models
  module HasContent
    extend ActiveSupport::Concern

    # include FixityCheckable

    included do
      has_file_datastream :name => "content", :type => DulHydra::Datastreams::FileContentDatastream
    end

    def validate_content_checksum
      self.validate_checksum("content")
    end

    def validate_content_checksum!
      self.validate_checksum!("content")
    end
      
  end
end
