module DulHydra::Migration
  class RDFDatastreamMerger < Migrator

    # source: Rubydora::DigitalObject

    def merge
      amd = source.datastreams['adminMetadata'].content
      dmd = source.datastreams['descMetadata'].content
      rdfmd = [ amd, dmd ].join("\n")
      unless rdfmd.blank?
        source.datastreams['mergedMetadata'].mimeType = 'application/n-triples'
        source.datastreams['mergedMetadata'].content = rdfmd
      end
    end

  end
end
