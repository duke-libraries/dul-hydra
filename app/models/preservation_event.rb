require 'json'

class PreservationEvent < ActiveFedora::Base

  before_create :assign_admin_policy
  after_save :update_for_object_index
    
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

  def fixity_check?
    event_type == FIXITY_CHECK
  end

  def success?
    event_outcome == SUCCESS
  end

  def failure?
    event_outcome == FAILURE
  end

  # # Options are :only and :except.
  # # Both take a String or Array with one or more datastream IDs
  # # :only takes precedence over except.
  # # Array operations should prevent invalid datastream ID issues.
  # def self.validate_checksums(obj, opts={})
  #   outcome = SUCCESS
  #   detail = {
  #     datastreams: {}, 
  #     options: opts, 
  #     version: DulHydra::VERSION
  #   }
  #   datastream_ids = obj.datastreams.keys
  #   if opts.has_key? :only
  #     include = opts[:only]
  #     include = [include] if include.is_a?(String)
  #     datastream_ids &= include
  #   elsif opts.has_key? :except
  #     exclude = opts[:except]
  #     exclude = [except] if except.is_a?(String)
  #     datastream_ids -= exclude
  #   end
  #   datastream_ids.each do |dsid|
  #     ds = obj.datastreams[dsid]
  #     outcome = FAILURE unless ds.dsChecksumValid
  #     detail[:datastreams][dsid] = ds.profile
  #   end
  #   new(:label => "Internal repository validation of datastream checksums",
  #       :event_type => FIXITY_CHECK,
  #       :event_date_time => to_event_date_time,
  #       :event_outcome => outcome,
  #       :event_detail => detail.to_json,
  #       :linking_object_id_type => OBJECT,
  #       :linking_object_id_value => obj.internal_uri,
  #       :for_object => obj
  #       )
  # end

  # def self.validate_checksums!(obj, opts={})
  #   pe = validate_checksums(obj, opts)
  #   pe.save!
  #   pe
  # end

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

  def update_for_object_index
    self.for_object.update_index if self.fixity_check?
  end

end

