#
# Abstract base class for vocabularies
#
module DulHydra
  module Metadata
    class Vocabulary

      def self.xmlns
        const_get(:XMLNS)
      end

      def self.namespace_prefix
        const_get(:NAMESPACE_PREFIX)
      end

      def self.term_names
        const_get(:TERMS)
      end

      def self.label
        const_get(:LABEL)
      end

    end
  end
end
