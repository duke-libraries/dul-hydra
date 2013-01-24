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
  
  has_metadata :name => "eventMetadata", :type => DulHydra::Datastreams::PremisEventDatastream, 
               :versionable => true, :label => "Preservation event metadata"

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
    ds = obj.datastreams[dsID]
    new(:label => "Checksum validation", 
        :event_type => FIXITY_CHECK,
        :event_date_time => to_event_date_time,
        :event_outcome => ds.dsChecksumValid ? SUCCESS : FAILURE,
        :event_detail => "Internal validation of checksum on repository object #{obj.internal_uri} datastream \"#{dsID}\" at version \"#{ds.dsVersionID}\" (created on #{DulHydra::Utils.ds_as_of_date_time(ds)}). DulHydra version #{DulHydra::VERSION}.",
        :linking_object_id_type => DATASTREAM,
        :linking_object_id_value => DulHydra::Utils.ds_internal_uri(obj, dsID),
        :for_object => obj
        )
  end

  def self.validate_checksum!(obj, dsID)
    pe = validate_checksum(obj, dsID)
    pe.save!
    obj.update_index # index last fixity check on for_object
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

  def self.to_event_date_time(t=Time.now.utc)
    t.strftime(DATE_TIME_FORMAT)
  end

end

