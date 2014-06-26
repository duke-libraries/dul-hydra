require 'rdf/rdfxml'

module DulHydra
  module Metadata
    class RDFVocabularyParser

      attr_reader :source, :prefix

      def initialize(source, prefix = "")
        @source = source
        @prefix = prefix
      end

      def term_names
        @term_names ||= terms.collect { |t| t[:resource].to_s.sub(prefix, "") }.freeze
      end

      def term_symbols
        term_names.map(&:to_sym)
      end

      def terms
        properties.map(&:to_hash)
      end

      def properties
        RDF::Query.execute(graph, properties_query)
      end

      def properties_query
        {:resource => {
            RDF.type => RDF.Property,
            RDF::RDFS.label => :label,
            RDF::RDFS.comment => :comment
          }
        }
      end

      def graph
        @graph ||= RDF::Graph.load(source).freeze
      end
      
    end
  end
end
