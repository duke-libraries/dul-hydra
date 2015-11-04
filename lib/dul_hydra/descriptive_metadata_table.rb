module DulHydra

  class DescriptiveMetadataTable < MetadataTable
    def datastream_id
      Ddr::Datastreams::DESC_METADATA
    end

    def terms
      Ddr::Models::DescriptiveMetadata.unqualified_names
    end
  end

end
