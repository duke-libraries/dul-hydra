class PreservationEvent < ActiveFedora::Base
    
  include DulHydra::Models::Governable
  include DulHydra::Models::AccessControllable

  DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"

  # Outcomes
  SUCCESS = "SUCCESS"
  FAILURE = "FAILURE"
  
  # Event types
  FIXITY_CHECK = "fixity check" # http://id.loc.gov/vocabulary/preservationEvents/fixityCheck
  INGEST = "ingest"             # http://id.loc.gov/vocabulary/preservationEvents/ingest
  
  has_metadata :name => "eventMetadata", :type => DulHydra::Datastreams::PremisEventDatastream, 
               :versionable => false, :label => "Preservation event metadata"

  belongs_to :for_object, :property => :is_preservation_event_for

  delegate_to :eventMetadata, [:event_date_time, :event_detail, :event_type, :event_id_type,
                               :event_id_value, :event_outcome, :event_outcome_detail_note,
                               :linking_object_id_type, :linking_object_id_value
                              ], :unique => true

  def fixity_check?
    self.event_type == FIXITY_CHECK
  end

  def self.validate_checksum(obj, dsID)
    ds = obj.datastreams[dsID]
    pe = PreservationEvent.new(:label => "Datastream checksum validation")
    pe.event_date_time = Time.now.utc.strftime(PreservationEvent::DATE_TIME_FORMAT)
    pe.event_outcome = ds.dsChecksumValid ? SUCCESS : FAILURE
    pe.linking_object_id_type = "datastream"
    pe.linking_object_id_value = "#{obj.internal_uri}/datastreams/#{dsID}?asOfDateTime=" + ds.dsCreateDate.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
    pe.event_type = FIXITY_CHECK
    pe.event_detail = "Datastream checksum validation"
    return pe
  end

end

