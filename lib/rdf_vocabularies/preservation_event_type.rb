require 'rdf'

class PreservationEventType < RDF::StrictVocabulary("http://id.loc.gov/vocabulary/preservation/eventType/")
  property :cap, label: "capture"
  property :com, label: "compression"
  property :cre, label: "creation"
  property :dea, label: "deaccession"
  property :dec, label: "decompression"
  property :der, label: "decryption"
  property :del, label: "deletion"
  property :dig, label: "digital signature validation"
  property :fix, label: "fixity check"
  property :ing, label: "ingestion"
  property :mes, label: "message digest calculation"
  property :mig, label: "migration"
  property :nor, label: "normalization"
  property :rep, label: "replication"
  property :val, label: "validation"
  property :vir, label: "virus check"
end
