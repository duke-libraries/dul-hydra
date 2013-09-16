class PreservationEvent < ActiveRecord::Base

  attr_accessible :event_detail, :event_date_time, :event_type, :event_outcome, :event_outcome_detail_note, 
                  :linking_object_id_type, :linking_object_id_value
  
  after_initialize :set_event_id
  after_initialize :set_event_date_time

  serialize :event_outcome_detail_note, JSON

  # Event types
  FIXITY_CHECK = "fixity check" # http://id.loc.gov/vocabulary/preservationEvents/fixityCheck
  INGESTION    = "ingestion"    # http://id.loc.gov/vocabulary/preservationEvents/ingestion
  VALIDATION   = "validation"   # http://id.loc.gov/vocabulary/preservationEvents/validation
  EVENT_TYPES = [FIXITY_CHECK, INGESTION, VALIDATION]

  # Outcomes
  SUCCESS = "success"
  FAILURE = "failure"
  EVENT_OUTCOMES = [SUCCESS, FAILURE]
  
  # Event identifier types
  UUID = "UUID"
  EVENT_ID_TYPES = [UUID]

  # Event date time - for PREMIS and Solr
  DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"

  # Linking object identifier types
  DATASTREAM = "datastream"
  OBJECT = "object"
  LINKING_OBJECT_ID_TYPES = [DATASTREAM, OBJECT]

  # Validation is based on PREMIS mandatory elements and controlled vocabulary values 
  # used in DulHydra.
  validates :event_date_time, presence: true
  validates :event_type, inclusion: {in: EVENT_TYPES, message: "%{value} is not a valid event type"}
  validates :event_outcome, inclusion: {in: EVENT_OUTCOMES, message: "%{value} is not a valid event outcome"}, allow_blank: true
  validates :event_id_type, inclusion: {in: EVENT_ID_TYPES, message: "%{value} is not a valid event identifier type"}
  validates :event_id_value, presence: true
  validates :linking_object_id_type, inclusion: {in: LINKING_OBJECT_ID_TYPES, message: "%{value} is not a valid linking object identifier type"}, if: "linking_object_id_value.present?"
  validates :linking_object_id_value, presence: true, if: "linking_object_id_type.present?"
  validate :for_object_must_exist_and_have_preservation_events
  
  def self.fixity_check(object)
    outcome, detail = object.validate_checksums
    pe = new(event_detail: "Validation of datastream checksums\nDulHydra version #{DulHydra::VERSION}",
             event_type: FIXITY_CHECK,
             event_outcome: outcome ? SUCCESS : FAILURE,
             event_outcome_detail_note: detail)
    pe.for_object = object
    pe
  end

  def self.fixity_check!(object)
    pe = PreservationEvent.fixity_check(object)
    pe.save
    pe
  end

  def save(*)
    super
    # Update ActiveFedora object in the Solr index
    for_object.update_index if for_object? && fixity_check?
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

  def for_object?
    linking_object_id_type == OBJECT
  end

  def for_object
    ActiveFedora::Base.find(self.linking_object_id_value, cast: true) if for_object?
  end

  def for_object=(object)
    self.linking_object_id_type = OBJECT
    self.linking_object_id_value = object.pid
  end

  # Validation method
  def for_object_must_exist_and_have_preservation_events
    if for_object?
      begin
        errors.add(:linking_object_id_value, "Object does not support preservation events") unless for_object.is_a?(DulHydra::Models::HasPreservationEvents)
      rescue ActiveFedora::ObjectNotFoundError
        errors.add(:linking_object_id_value, "Object not found in the repository")
      end
    end
  end

  def self.events_for(object, event_type=nil)
    params = {
      linking_object_id_type: OBJECT,
      linking_object_id_value: object.pid
      }
    params[:event_type] = event_type if event_type
    PreservationEvent.where(params).order("event_date_time ASC")
  end

  # Return a date/time formatted as a string suitable for use as a PREMIS eventDateTime.
  # Format also works for Solr.
  def self.to_event_date_time(t=Time.now.utc)
    t.strftime(DATE_TIME_FORMAT)
  end

  private

  def set_event_id
    self.event_id_type = UUID
    self.event_id_value = SecureRandom.uuid
  end

  def set_event_date_time
    self.event_date_time = Time.now.utc unless self.event_date_time
  end

end

