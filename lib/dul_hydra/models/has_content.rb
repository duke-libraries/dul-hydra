module DulHydra::Models
  module HasContent
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => "content", :type => DulHydra::Datastreams::FileContentDatastream
    end

    def validate_content_checksum
      validate_checksum("content")
    end

    def validate_content_checksum!
      validate_checksum!("content")
    end
      
  end
end
