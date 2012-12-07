module DulHydra::Models
  module Describable
    extend ActiveSupport::Concern
   
    included do
      has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream
      delegate_to "descMetadata", [:title, :identifier]
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
