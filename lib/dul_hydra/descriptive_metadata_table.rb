module DulHydra

  class DescriptiveMetadataTable < MetadataTable
    def datastream_id
      Ddr::Datastreams::DESC_METADATA
    end

    def terms
      Ddr::Datastreams::DescriptiveMetadataDatastream.term_names
    end
  end

end
