module DulHydra
  module Metadata
    class Vocabulary

      def self.label(rdf_vocabulary)
        case rdf_vocabulary.to_uri
        when RDF::DC.to_uri
          "DC Terms"
        when DukeTerms.to_uri
          "Duke Terms"
        end
      end

      def self.namespace_prefix(rdf_vocabulary)
        case rdf_vocabulary.to_uri
        when RDF::DC.to_uri
          "dcterms"
        when DukeTerms.to_uri
          "duke"
        end
      end

      def self.property_terms(rdf_vocabulary)
        rdf_vocabulary.properties.select { |p| p.type.include?("http://www.w3.org/1999/02/22-rdf-syntax-ns#Property") }
      end

      def self.term_names(rdf_vocabulary)
        self.property_terms(rdf_vocabulary).map { |term| self.term_name(rdf_vocabulary, term) }
      end

      def self.term_name(rdf_vocabulary, term)
        term.to_s.gsub(rdf_vocabulary.to_uri.to_s, "").to_sym
      end

    end
  end
end
