#
# Abstract base class for vocabularies
#
module DulHydra
  module Metadata
    class Vocabulary

      class_attribute :xmlns, :namespace_prefix

      def self.term_names
        raise NotImplementedError
      end

    end
  end
end
