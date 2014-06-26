module DulHydra
  module Describable
    extend ActiveSupport::Concern
   
    included do
      has_metadata name: DulHydra::Datastreams::DESC_METADATA, 
                   type: DulHydra::Datastreams::DescriptiveMetadataDatastream,
                   versionable: true, 
                   label: "Descriptive Metadata for this object", 
                   control_group: 'M'
      DulHydra::Metadata::DCTerms::ELEMENTS_11.each do |element|
        has_attributes element, datastream: DulHydra::Datastreams::DESC_METADATA, multiple: true
      end
    end

    def descriptive_metadata_terms
      DulHydra::Metadata::DCTerms::ELEMENTS_11
    end

    def terms_for_editing
      [:title,
       :description, 
       :identifier, 
       :contributor,
       :coverage, 
       :creator, 
       :date, 
       :format,
       :language, 
       :publisher, 
       :relation, 
       :rights,
       :source, 
       :subject,
       :type]
    end
    
    def descriptive_metadata_editable?
      return descmetadata_source.nil?
    end

    module ClassMethods
      def find_by_identifier(identifier)
        find(DulHydra::IndexFields::IDENTIFIER => identifier)
      end
    end

  end
end
