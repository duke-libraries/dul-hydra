module DulHydra::Models
  module HasContent
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::CONTENT, :type => DulHydra::Datastreams::FileContentDatastream
    end

    def has_content?
      !datastreams[DulHydra::Datastreams::CONTENT].profile.empty?
    end

    def validate_content_checksum
      validate_checksum(DulHydra::Datastreams::CONTENT)
    end

    def validate_content_checksum!
      validate_checksum!(DulHydra::Datastreams::CONTENT)
    end
      
  end
end
