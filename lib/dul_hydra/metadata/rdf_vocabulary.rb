require 'rdf/rdfxml'

module DulHydra
  module Metadata

    # Vocabulary loaded from RDF source
    class RDFVocabulary < Vocabulary

      class_attribute :source

        def self.term_names
          @term_names ||= terms.collect { |t| t[:resource].to_s.sub(term_prefix, "").to_sym }.freeze
        end

        def self.terms
          properties.map(&:to_hash)
        end

        def self.term_prefix
          xmlns
        end

        def self.properties
          RDF::Query.execute(graph, properties_query)
        end

        def self.properties_query
          {:resource => {
              RDF.type => RDF.Property,
              RDF::RDFS.label => :label,
              RDF::RDFS.comment => :comment
            }
          }
        end

        def self.graph
          @graph ||= RDF::Graph.load(source).freeze
        end
      
    end
  end
end
