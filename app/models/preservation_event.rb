class PreservationEvent < ActiveRecord::Base
  extend Deprecation

  after_initialize :deprecation_warning
  after_initialize :set_event_id
  after_initialize :set_event_date_time, if: "event_date_time.nil?"
  after_save :update_index_for_object, if: :update_index?

  # Event types
  FIXITY_CHECK = "fixity check" # http://id.loc.gov/vocabulary/preservationEvents/fixityCheck
  INGESTION    = "ingestion"    # http://id.loc.gov/vocabulary/preservationEvents/ingestion
  VALIDATION   = "validation"   # http://id.loc.gov/vocabulary/preservationEvents/validation
  CREATION     = "creation"     # http://id.loc.gov/vocabulary/preservationEvents/creation
  VIRUS_CHECK  = "virus check"  # http://id.loc.gov/vocabulary/preservation/eventType/vir.html
  EVENT_TYPES = [FIXITY_CHECK, INGESTION, VALIDATION, CREATION, VIRUS_CHECK]

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
  validate :for_object_must_exist

  def fixity_check?
    event_type == FIXITY_CHECK
  end

  def virus_check?
    event_type == VIRUS_CHECK
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
  def for_object_must_exist
    if for_object?
      begin
        for_object
      rescue ArgumentError => e
        errors.add(:linking_object_id_value, e.message)
      rescue ActiveFedora::ObjectNotFoundError => e
        errors.add(:linking_object_id_value, e.message)
      end
    end
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

  protected

  def deprecation_warning
    Deprecation.warn(PreservationEvent, "PreservationEvent is deprecated and will be removed in DulHydra 2.0.0.")
  end

  def update_index_for_object
    for_object.update_index
  end

  # Whether we should update the index of the related object after save
  def update_index?
    for_object? && (fixity_check? || virus_check?)
  end

  private

  def set_event_id
    self.event_id_type = UUID
    self.event_id_value = SecureRandom.uuid
  end

  def set_event_date_time
    self.event_date_time = Time.now.utc
  end

  def self.version_note
    "DulHydra version #{DulHydra::VERSION}"
  end

end
