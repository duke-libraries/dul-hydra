module DulHydra::Models
  module Describable
    extend ActiveSupport::Concern
   
    included do
      has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream
      delegate_to "descMetadata", [:title, :identifier]

      def self.find_by_identifier(identifier)
        self.find(:identifier_t => identifier)
        # results = []
        # self.find_each("identifier_s:#{identifier}*") do |x| 
        #   results << x
        # end
        # results
      end

      def has_title?
        !(title.empty? || title.first.length == 0)
      end

      def display_title
        has_title? ? title.first : pid
      end
    end # included

  end # Describable
end
