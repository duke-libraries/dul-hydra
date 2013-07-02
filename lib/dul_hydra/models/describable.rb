module DulHydra::Models
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
                     :title
                    ]


    included do
      has_metadata :name => DulHydra::Datastreams::DESC_METADATA, 
                   :type => ActiveFedora::QualifiedDublinCoreDatastream,
                   :versionable => true, 
                   :label => "Descriptive Metadata for this object", 
                   :control_group => 'X'
      delegate_to DulHydra::Datastreams::DESC_METADATA, DC11_ELEMENTS
      delegate :dc_type, to: DulHydra::Datastreams::DESC_METADATA
      after_initialize :add_dc_type
    end

    module ClassMethods
      def find_by_identifier(identifier)
        find(DulHydra::IndexFields::IDENTIFIER => identifier)
      end
    end

    protected

    def add_dc_type
      datastreams[DulHydra::Datastreams::DESC_METADATA].field(:dc_type, :string, {path: "type", multiple: true})
    end

  end
end
