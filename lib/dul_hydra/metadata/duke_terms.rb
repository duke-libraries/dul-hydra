module DulHydra
  module Metadata
    class DukeTerms < RDFVocabulary

      self.xmlns = "http://library.duke.edu/metadata/terms".freeze

      self.namespace_prefix = "duke".freeze

      self.source = File.join(Rails.root, 'config', 'duketerms.rdf.xml')

      def self.term_prefix
        "#{xmlns}/"
      end

    end
  end
end
