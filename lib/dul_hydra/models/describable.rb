module DulHydra::Models
  module Describable
    extend ActiveSupport::Concern
   
    included do

      has_metadata :name => "descMetadata", :type => DulHydra::Datastreams::ModsDatastream
      delegate_to "descMetadata", [:title, :identifier]

      def self.find_by_identifier(identifier)
        results = []
        self.find_each("identifier_s:#{identifier}*") do
          |x| results << x
        end
        results
      end

    end # included

  end # Describable
end
