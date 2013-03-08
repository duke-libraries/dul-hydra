module DulHydra::Models
  module Describable
    extend ActiveSupport::Concern
   
    included do
      has_metadata :name => DulHydra::Datastreams::DESC_METADATA, :type => ActiveFedora::QualifiedDublinCoreDatastream
      delegate_to DulHydra::Datastreams::DESC_METADATA, [:title, :identifier, :creator, :source]
    end

    def has_title?
      !(title.empty? || title.first.length == 0)
    end

    def display_title
      has_title? ? title.first : pid
    end

    module ClassMethods
      def find_by_identifier(identifier)
        find(:identifier_t => identifier)
      end
    end

  end
end
