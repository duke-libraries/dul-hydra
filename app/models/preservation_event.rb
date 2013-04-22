require 'json'

class PreservationEvent < ActiveFedora::Base

  before_create :assign_admin_policy
  after_save :update_index_for_object
    
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
  
  has_metadata :name => DulHydra::Datastreams::EVENT_METADATA, :type => DulHydra::Datastreams::PremisEventDatastream, 
               :versionable => true, :label => "Preservation event metadata", :control_group => 'X'

  belongs_to :for_object, 
             :property => :is_preservation_event_for, 
             :class_name => 'DulHydra::Models::HasPreservationEvents'

  delegate_to :eventMetadata, [:event_date_time, :event_detail, :event_type, :event_id_type,
                               :event_id_value, :event_outcome, :event_outcome_detail_note,
                               :linking_object_id_type, :linking_object_id_value
                              ], :unique => true


  def self.fixity_check(object)
    outcome, detail = object.validate_checksums
    pe = new(:for_object => object,
             :label => "Validation of datastream checksums",
             :event_date_time => to_event_date_time,
             :event_type => FIXITY_CHECK,
             :event_outcome => outcome ? SUCCESS : FAILURE,
             :linking_object_id_type => OBJECT,
             :linking_object_id_value => object.internal_uri)
    pe.fixity_check_detail = detail
    pe
  end

  def fixity_check_detail
    JSON.parse(event_outcome_detail_note)
  end

  def fixity_check_detail=(detail)
    event_outcome_detail_note = detail.to_json
  end

  def self.fixity_check!(object)
    pe = PreservationEvent.fixity_check(object)
    pe.save
    pe
  end

  def fixity_check?
    event_type == FIXITY_CHECK
  end

  def success?
    event_outcome == SUCCESS
  end

  def failure?
    event_outcome == FAILURE
  end

  def self.events_for(object, type)
    PreservationEvent.where(ActiveFedora::SolrService.solr_name(:is_preservation_event_for, :symbol) => object.internal_uri,
                            ActiveFedora::SolrService.solr_name(:event_type, :symbol) => type
                            ).order("#{ActiveFedora::SolrService.solr_name(:event_date_time, :date)} asc")
  end

  # Overriding to_solr here seems cleaner than using :index_as on eventMetadata OM terminology.
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

  # Return a date/time formatted as a string suitable for use as a PREMIS eventDateTime.
  def self.to_event_date_time(t=Time.now.utc)
    t.strftime(DATE_TIME_FORMAT)
  end

  def self.default_admin_policy
    AdminPolicy.find(DulHydra::AdminPolicies::PRESERVATION_EVENTS) rescue nil
  end

  private

  def assign_admin_policy
    self.admin_policy = PreservationEvent.default_admin_policy unless self.admin_policy
  end

  def update_index_for_object
    for_object.update_index if fixity_check?
  end

end

