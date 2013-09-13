require 'json'

class PreservationEvent < ActiveRecord::Base

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
  
  # delegate_to :eventMetadata, [:event_date_time, :event_detail, :event_type, :event_id_type,
  #                              :event_id_value, :event_outcome, :event_outcome_detail_note,
  #                              :linking_object_id_type, :linking_object_id_value
  #                             ], :unique => true

  def self.fixity_check(object)
    outcome, detail = object.validate_checksums
    pe = new(:object_pid => object.pid,
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
    JSON.parse(self.event_outcome_detail_note)
  end

  def fixity_check_detail=(detail)
    self.event_outcome_detail_note = detail.to_json
  end

  def self.fixity_check!(object)
    pe = PreservationEvent.fixity_check(object)
    pe.save
    pe
  end

  def save(*)
    super
    self.for_object.update_index if self.fixity_check?
  end

  def fixity_check?
    self.event_type == FIXITY_CHECK
  end

  def success?
    self.event_outcome == SUCCESS
  end

  def failure?
    self.event_outcome == FAILURE
  end

  def for_object
    ActiveFedora::Base.find(self.object_pid, cast: true)
  end

  def self.events_for(object, event_type)
    PreservationEvent.where(object_pid: object.pid, event_type: event_type).order("event_date_time ASC")
  end

  # Return a date/time formatted as a string suitable for use as a PREMIS eventDateTime.
  def self.to_event_date_time(t=Time.now.utc)
    t.strftime(DATE_TIME_FORMAT)
  end

end

