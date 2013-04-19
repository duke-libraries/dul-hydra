require 'json'

class PreservationEvent < ActiveFedora::Base

  before_create :assign_admin_policy
    
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
  
#   # String template for fixity check/checksum validation event detail 
#   CHECKSUM_VALIDATION_EVENT_DETAIL = <<EOS
# Internal validation of datastream checksums.
# Results: 
# [DulHydra version #{DulHydra::VERSION}]
# EOS
  
  has_metadata :name => DulHydra::Datastreams::EVENT_METADATA, :type => DulHydra::Datastreams::PremisEventDatastream, 
               :versionable => true, :label => "Preservation event metadata", :control_group => 'X'

  belongs_to :for_object, 
             :property => :is_preservation_event_for, 
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

  def self.validate_checksums(obj)
    results = {}
    outcome = SUCCESS
    obj.datastreams.each do |dsid, ds|
      outcome = FAILURE unless ds.dsChecksumValid
      results[dsid] = ds.profile(:validateChecksum => true)
    end
    new(:label => "Checksum validation", 
        :event_type => FIXITY_CHECK,
        :event_date_time => to_event_date_time,
        :event_outcome => ds.dsChecksumValid ? SUCCESS : FAILURE,
        :event_detail => CHECKSUM_VALIDATION_EVENT_DETAIL % {
                           :uri => obj.internal_uri,
                           :dsID => dsID,
                           :dsVersionID => ds.dsVersionID,
                           :dsCreateDate => DulHydra::Utils.ds_as_of_date_time(ds)
                           },  
        :linking_object_id_type => OBJECT,
        :linking_object_id_value => obj.internal_uri
        :for_object => obj
        )
  end

  def self.validate_checksum!(obj)
    pe = validate_checksums(obj)
    pe.save!
    # index last fixity check on for_object
    # XXX should this be in an after_save callback?
    obj.update_index 
    return pe
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

end

