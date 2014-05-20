module DulHydra
  module Metadata
    class DCTerms < RDFVocabulary

      self.xmlns = "http://purl.org/dc/terms/".freeze

      self.namespace_prefix = "dcterms".freeze

      self.source = File.join(Rails.root, 'config', 'dcterms.rdf')

    end
  end
end
