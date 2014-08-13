module DulHydra
  module Describable
    extend ActiveSupport::Concern
   
    included do
      has_metadata name: DulHydra::Datastreams::DESC_METADATA, 
                   type: DulHydra::Datastreams::DescriptiveMetadataDatastream,
                   versionable: true, 
                   label: "Descriptive Metadata for this object", 
                   control_group: 'M'
      has_attributes *DulHydra::Metadata::Vocabulary.term_names(RDF::DC11),
                     datastream: DulHydra::Datastreams::DESC_METADATA, 
                     multiple: true
    end

    def desc_metadata_terms *args
      return DulHydra::Datastreams::DescriptiveMetadataDatastream.term_names if args.empty?
      arg = args.pop
      terms = case arg.to_sym
              when :empty
                desc_metadata_terms.select { |t| desc_metadata_values(t).empty? }
              when :present
                desc_metadata_terms.select { |t| desc_metadata_values(t).present? }
              when :defined_attributes
                desc_metadata_terms & desc_metadata_attributes
              when :required
                desc_metadata_terms(:defined_attributes).select {|t| required? t}
              when :dcterms
                DulHydra::Metadata::Vocabulary.term_names(RDF::DC11) +
                      (DulHydra::Metadata::Vocabulary.term_names(RDF::DC) - DulHydra::Metadata::Vocabulary.term_names(RDF::DC11))
              when :dcterms_elements11
                DulHydra::Metadata::Vocabulary.term_names(RDF::DC11)
              when :duke
                DulHydra::Metadata::Vocabulary.term_names(DukeTerms)
              else
                raise ArgumentError, "Invalid argument: #{arg.inspect}"
              end
      if args.empty?
        terms
      else 
        terms | desc_metadata_terms(*args)
      end
    end

    def desc_metadata_attributes
      defattrs = self.class.defined_attributes
      defattrs.keys.select {|k| defattrs[k].dsid == "descMetadata"}.map(&:to_sym)
    end

    def desc_metadata_values term
      descMetadata.values term
    end

    def desc_metadata_vocabs
      descMetadata.class.vocabularies
    end

    def set_desc_metadata_values term, values
      descMetadata.set_values term, values
    end

    # Update all descMetadata terms with values in hash
    # Note that term not having key in hash will be set to nil!
    def set_desc_metadata term_values_hash
      desc_metadata_terms.each { |t| set_desc_metadata_values(t, term_values_hash[t]) }
    end

    module ClassMethods
      def find_by_identifier(identifier)
        find(DulHydra::IndexFields::IDENTIFIER => identifier)
      end
    end

  end
end
