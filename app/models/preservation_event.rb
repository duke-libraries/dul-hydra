class PreservationEvent < ActiveRecord::Base

#  attr_accessible :event_detail, :event_date_time, :event_type, :event_outcome, :event_outcome_detail_note, 
#                  :linking_object_id_type, :linking_object_id_value
  
  after_initialize :set_event_id
  after_initialize :set_event_date_time

  # Event types
  FIXITY_CHECK = "fixity check" # http://id.loc.gov/vocabulary/preservationEvents/fixityCheck
  INGESTION    = "ingestion"    # http://id.loc.gov/vocabulary/preservationEvents/ingestion
  VALIDATION   = "validation"   # http://id.loc.gov/vocabulary/preservationEvents/validation
  CREATION     = "creation"     # http://id.loc.gov/vocabulary/preservationEvents/creation
  EVENT_TYPES = [FIXITY_CHECK, INGESTION, VALIDATION, CREATION]

  # Outcomes
  SUCCESS = "success"
  FAILURE = "failure"
  EVENT_OUTCOMES = [SUCCESS, FAILURE]

  # Fixity checks
  VALID = "VALID"
  INVALID = "INVALID"
  
  # Event identifier types
  UUID = "UUID"
  EVENT_ID_TYPES = [UUID]

  # Event date time - for PREMIS and Solr
  DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"

  # Linking object identifier types
  DATASTREAM = "datastream"
  OBJECT = "object"
  LINKING_OBJECT_ID_TYPES = [DATASTREAM, OBJECT]

  DEFAULT_SORT_ORDER = "event_date_time ASC"

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

  # Return a new fixity check PreservationEvent for the object
  def self.fixity_check(object)
    outcome, results = object.validate_checksums
    outcome_detail_note = ["Datastream checksum validation results:"]
    results.each do |dsid, dsProfile|
      outcome_detail_note << "%s ... %s" % [dsid, dsProfile["dsChecksumValid"] ? VALID : INVALID]
    end
    pe = new(event_detail: "Validation of datastream checksums\nDulHydra version #{DulHydra::VERSION}",
             event_type: FIXITY_CHECK,
             event_outcome: outcome ? SUCCESS : FAILURE,
             event_outcome_detail_note: outcome_detail_note.join("\n")
             )
    pe.for_object = object
    pe
  end

  # Return a persisted fixity check PreservationEvent for the object
  def self.fixity_check!(object)
    pe = PreservationEvent.fixity_check(object)
    pe.save
    pe
  end

  # Return a new creation PreservationEvent for the object, user
  def self.creation(object, user=nil)
    event_detail = "New #{object.class.to_s} object created"
    event_detail << " by #{user.user_key}" if user
    event_detail << ".\n#{version_note}"
    pe = new(event_detail: event_detail,
             event_type: CREATION)
    pe.for_object = object
    pe
  end

  # Return a persisted creation PreservationEvent for the object, user
  def self.creation!(object, user=nil)
    factory!(:creation, object, user)
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
    # Raises ArgumentError and ActiveFedora::ObjectNotFoundError
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
        errors.add(:linking_object_id_value, "Object does not support preservation events") unless for_object.is_a?(DulHydra::HasPreservationEvents)
      rescue ArgumentError => e
        errors.add(:linking_object_id_value, e.message)
      rescue ActiveFedora::ObjectNotFoundError => e
        errors.add(:linking_object_id_value, e.message)
      end
    end
  end

  def self.events_for(object_or_pid, event_type=nil)
    raise TypeError, 'Invalid event type' unless event_type.nil? || EVENT_TYPES.include?(event_type)
    if object_or_pid.is_a?(DulHydra::HasPreservationEvents)
      pid = object_or_pid.pid
    elsif object_or_pid.is_a?(String)
      pid = object_or_pid
    else
      raise TypeError, "First argument must be a DulHydra::HasPreservationEvents or a PID string."
    end
    params = {
      linking_object_id_type: OBJECT,
      linking_object_id_value: pid
      }
    params[:event_type] = event_type unless event_type.nil?
    PreservationEvent.where(params).order(DEFAULT_SORT_ORDER)
  end

  # Return a date/time formatted as a string suitable for use as a PREMIS eventDateTime.
  # Format also works for Solr.
  def self.to_event_date_time(t=Time.now.utc)
    t.strftime(DATE_TIME_FORMAT)
  end

  def as_premis
    doc = DulHydra::Metadata::PremisEvent.new
    doc.event_type = self.event_type
    doc.event_id_type = self.event_id_type
    doc.event_id_value = self.event_id_value
    doc.event_detail = self.event_detail
    doc.linking_object_id_type = self.linking_object_id_type
    doc.linking_object_id_value = self.linking_object_id_value
    doc.event_outcome = self.event_outcome
    doc.event_outcome_detail_note = self.event_outcome_detail_note
    doc.event_date_time = PreservationEvent.to_event_date_time(self.event_date_time)
    doc
  end

  def to_xml
    as_premis.to_xml
  end

  private

  def self.factory!(method, *args)
    pe = PreservationEvent.send(method, *args)
    pe.save!
    pe
  end

  def set_event_id
    self.event_id_type = UUID
    self.event_id_value = SecureRandom.uuid
  end

  def set_event_date_time
    self.event_date_time = Time.now.utc unless self.event_date_time
  end

  def self.version_note
    "DulHydra version #{DulHydra::VERSION}"
  end

end
