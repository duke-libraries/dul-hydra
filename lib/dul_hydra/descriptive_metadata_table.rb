module DulHydra

  class DescriptiveMetadataTable < MetadataTable
    def datastream_id
      DulHydra::Datastreams::DESC_METADATA
    end

    def terms
      ActiveFedora::QualifiedDublinCoreDatastream::DCTERMS
    end
  end

end
