module DulHydra

  class DescriptiveMetadataTable < MetadataTable
    def datastream_id
      DulHydra::Datastreams::DESC_METADATA
    end

    def terms
      DulHydra::Datastreams::DescriptiveMetadataDatastream.term_names
    end
  end

end
