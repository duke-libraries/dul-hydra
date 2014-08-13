module DulHydra
  module Datastreams
    class DescriptiveMetadataDatastream < ActiveFedora::NtriplesRDFDatastream

      class_attribute :vocabularies
      self.vocabularies = [RDF::DC, DukeTerms].freeze

      def self.default_attributes
        super.merge(:mimeType => 'application/n-triples')
      end

      def self.indexers
        # Add term_name => [indexers] mapping to customize indexing
        {}
      end

      def self.default_indexers
        [:stored_searchable]
      end

      def self.indexers_for(term_name)
        indexers.fetch(term_name, default_indexers)
      end

      def self.term_names
        terms = []
        vocabularies.each do |vocab|
          terms |= DulHydra::Metadata::Vocabulary.term_names(vocab)
        end
        terms.sort
      end

      # Add terms from the vocabularies as properties
      vocabularies.each do |vocab|
        vocab.each do |term|
          term_name = DulHydra::Metadata::Vocabulary.term_name(vocab, term)
          property term_name, predicate: term do |index|
            index.as *indexers_for(term_name)
          end
        end
      end
     
      # Returns ActiveFedora::Rdf::Term now that this is an RDF datastream
      def values term
        term == :format ? self.format : self.send(term)
      end

      # Update term with values
      # Note that empty values (nil or "") are rejected from values array
      def set_values term, values
        if values.respond_to?(:reject!)
          values.reject! { |v| v.blank? }
        else
          values = nil if values.blank?
        end
        begin
          self.send("#{term}=", values)
        rescue NoMethodError
          raise ArgumentError, "No such term: #{term}"
        end
      end

      # Add value to term
      # Note that empty value (nil or "") is not added
      def add_value term, value
        begin
          unless value.blank?
            values = values(term).to_a << value
            set_values term, values
          end
        rescue NoMethodError
          raise ArgumentError, "No such term: #{term}"
        end
      end

      # Override ActiveFedora::Rdf::Indexing#apply_prefix(name) to not
      # prepend the index field name with a string based on the datastream id.
      def apply_prefix(name)
        name
      end

    end
  end
end
