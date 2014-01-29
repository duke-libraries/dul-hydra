module DulHydra
  module Describable
    extend ActiveSupport::Concern
   
    DC11_ELEMENTS = [ # Dublin Core 1.1 element set, excluding :format and :type
                     :contributor,
                     :coverage, 
                     :creator, 
                     :date, 
                     :description, 
                     :identifier, 
                     :language, 
                     :publisher, 
                     :relation, 
                     :rights,
                     :source, 
                     :subject,
                     :title,
                     :type
                    ]

    included do
      has_metadata :name => DulHydra::Datastreams::DESC_METADATA, 
                   :type => ActiveFedora::QualifiedDublinCoreDatastream,
                   :versionable => true, 
                   :label => "Descriptive Metadata for this object", 
                   :control_group => 'X'
      DC11_ELEMENTS.each do |element|
        has_attributes element, datastream: DulHydra::Datastreams::DESC_METADATA, multiple: true
      end
    end

    def descriptive_metadata_terms
      DC11_ELEMENTS
    end

    def terms_for_editing
      descriptive_metadata_terms
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
