class PreservationEvent < ActiveFedora::Base
    
  include DulHydra::Models::Governable
  include DulHydra::Models::AccessControllable

  # Event date time
  DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"

  # Outcomes
  SUCCESS = "success"
  FAILURE = "failure"
  
  # Event types
  FIXITY_CHECK = "fixity check" # http://id.loc.gov/vocabulary/preservationEvents/fixityCheck
  INGESTION    = "ingestion"    # http://id.loc.gov/vocabulary/preservationEvents/ingestion
  VALIDATION   = "validation"   # http://id.loc.gov/vocabulary/preservationEvents/validation

  # Event identifier types
  UUID = "UUID"

  # Linking object identifier types
  DATASTREAM = "datastream"
  OBJECT = "object"
  
  has_metadata :name => "eventMetadata", :type => DulHydra::Datastreams::PremisEventDatastream, 
               :versionable => false, :label => "Preservation event metadata"

  # DulHydra::Models::HasPreservationEvents defines an inbound has_many relationship to PreservationEvent
  belongs_to :for_object, :property => :is_preservation_event_for, 
             :class_name => 'DulHydra::Models::HasPreservationEvents'

  delegate_to :eventMetadata, [:event_date_time, :event_detail, :event_type, :event_id_type,
                               :event_id_value, :event_outcome, :event_outcome_detail_note,
                               :linking_object_id_type, :linking_object_id_value
                              ], :unique => true

  def fixity_check?
    event_type == FIXITY_CHECK
  end

  def success?
    event_outcome == SUCCESS
  end

  def failure?
    event_outcome == FAILURE
  end

  def self.validate_checksum(obj, dsID)
    pe = PreservationEvent.new(:label => "Datastream checksum validation")
    pe.event_date_time = Time.now.utc.strftime(PreservationEvent::DATE_TIME_FORMAT)
    pe.event_outcome = obj.datastreams[dsID].dsChecksumValid ? SUCCESS : FAILURE
    pe.linking_object_id_type = DATASTREAM
    pe.linking_object_id_value = "#{obj.internal_uri}/datastreams/#{dsID}?asOfDateTime=%s" % obj.datastreams[dsID].dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
    pe.event_type = FIXITY_CHECK
    pe.event_detail = "Datastream checksum validation"
    pe.for_object = obj
    return pe
  end

  def self.validate_checksum!(obj, dsID)
    pe = PreservationEvent.validate_checksum(obj, dsID)
    pe.save!
    obj.update_index # index last fixity check
    return pe
  end

  def to_solr(solr_doc=Hash.new, opts={})
    solr_doc = super(solr_doc, opts)
    solr_doc.merge!(ActiveFedora::SolrService.solr_name(:event_date_time, :date) => event_date_time,
                    ActiveFedora::SolrService.solr_name(:event_type, :symbol) => event_type,
                    ActiveFedora::SolrService.solr_name(:event_outcome, :symbol) => event_outcome,
                    ActiveFedora::SolrService.solr_name(:event_id_type, :symbol) => event_id_type,
                    ActiveFedora::SolrService.solr_name(:event_id_value, :symbol) => event_id_value,                    
                    ActiveFedora::SolrService.solr_name(:linking_object_id_type, :symbol) => linking_object_id_type,
                    ActiveFedora::SolrService.solr_name(:linking_object_id_value, :symbol) => linking_object_id_value)
    return solr_doc
  end

end

