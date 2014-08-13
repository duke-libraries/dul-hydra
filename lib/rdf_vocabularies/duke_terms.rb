class DukeTerms < RDF::StrictVocabulary("http://library.duke.edu/metadata/terms/")

  DulHydra::Metadata::RDFVocabularyParser.new(
          "#{Rails.root}/lib/rdf_vocabularies/sources/duketerms.rdf.xml",
          "http://library.duke.edu/metadata/terms/").
          term_symbols.sort.each do |term|
    property term, type: "rdf:Property".freeze
  end

end
