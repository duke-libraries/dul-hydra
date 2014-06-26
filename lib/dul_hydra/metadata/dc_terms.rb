module DulHydra
  module Metadata
    class DCTerms < Vocabulary

      XMLNS = "http://purl.org/dc/terms/".freeze

      NAMESPACE_PREFIX = "dcterms".freeze

      # DCMI metadata terms - properties in the /terms/ namespace
      # Version 2012-06-14
      TERMS = [:abstract,
               :accessRights,
               :accrualMethod,
               :accrualPeriodicity,
               :accrualPolicy,
               :alternative,
               :audience,
               :available,
               :bibliographicCitation,
               :conformsTo,
               :contributor,
               :coverage,
               :created,
               :creator,
               :date,
               :dateAccepted,
               :dateCopyrighted,
               :dateSubmitted,
               :description,
               :educationLevel,
               :extent,
               :format,
               :hasFormat,
               :hasPart,
               :hasVersion,
               :identifier,
               :instructionalMethod,
               :isFormatOf,
               :isPartOf,
               :isReferencedBy,
               :isReplacedBy,
               :isRequiredBy,
               :isVersionOf,
               :issued,
               :language,
               :license,
               :mediator,
               :medium,
               :modified,
               :provenance,
               :publisher,
               :references,
               :relation,
               :replaces,
               :requires,
               :rights,
               :rightsHolder,
               :source,
               :spatial,
               :subject,
               :tableOfContents,
               :temporal,
               :title,
               :type,
               :valid].freeze

      # DCMI metadata terms - properties in the /elements/1.1/ namespace
      ELEMENTS_11 = [:contributor, 
                     :coverage,
                     :creator,
                     :date,
                     :description,
                     :format,
                     :identifier,
                     :language,
                     :publisher,
                     :relation,
                     :rights,
                     :source,
                     :subject,
                     :title,
                     :type].freeze

    end
  end
end
