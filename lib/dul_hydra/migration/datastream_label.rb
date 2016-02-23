module DulHydra::Migration
  class DatastreamLabel < Migrator

    # source: Rubydora::DigitalObject
    # target: AF::Base

    def prepare
      source.datastreams.each do |dsid, datastream|
        if [ 'content', 'thumbnail', 'fits', 'structMetadata', 'extractedText' ].include?(dsid)
          datastream.dsLabel = new_label(dsid, datastream)
        end
      end
    end

    private

    def new_label(dsid, datastream)
      if datastream.content.present?
        case dsid
          when 'content'
            original_name_from_admin_metadata
          when 'thumbnail'
            'thumbnail.png'
        end
      end
    end

    def original_name_from_admin_metadata
      if ds = source.datastreams['adminMetadata']
        graph = RDF::Graph.new.from_ntriples(ds.content)
        query = RDF::Query.new do
          pattern [nil, RDF::Vocab::PREMIS.hasOriginalName, :filename]
        end
        solutions = query.execute(graph)
        solutions.first.filename.to_s
      end
    end
  end
end
