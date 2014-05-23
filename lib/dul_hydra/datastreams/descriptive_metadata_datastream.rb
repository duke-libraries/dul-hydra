require 'dul_hydra/metadata/dc_terms'
require 'dul_hydra/metadata/duke_terms'

module DulHydra
  module Datastreams
    class DescriptiveMetadataDatastream < ActiveFedora::OmDatastream

      class_attribute :vocabularies
      self.vocabularies = [DulHydra::Metadata::DCTerms, DulHydra::Metadata::DukeTerms].freeze

      def self.indexers
        # Add term_name => [indexers] mapping to customize indexing
        {}
      end

      def self.om_term_opts(vocab)
        {xmlns: vocab.xmlns, namespace_prefix: vocab.namespace_prefix}        
      end

      def self.default_indexers
        [:stored_searchable]
      end

      def self.indexers_for(term_name)
        indexers.fetch(term_name, default_indexers)
      end
         
      set_terminology do |t|
        t.root(path: "dc")
      end

      # Add terms from the vocabularies to the terminology
      vocabularies.each do |vocab|
        vocab.term_names.each do |t|
          next if terminology.has_term? t
          opts = om_term_opts(vocab).merge(index_as: indexers_for(t))
          term = OM::XML::Term.new t, opts
          terminology.add_term term.generate_xpath_queries!
        end
      end
     
      def self.xml_template
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.dc
        end
        vocabularies.each do |vocab|
          builder.doc.root.add_namespace(vocab.namespace_prefix, vocab.xmlns)
        end
        builder.doc
      end

      def prefix
        ""
      end

    end
  end
end
