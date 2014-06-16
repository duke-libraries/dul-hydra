class Event < ActiveRecord::Base

  belongs_to :user, inverse_of: :events

  # Event date time - for PREMIS and Solr
  DATE_TIME_FORMAT = "%Y-%m-%dT%H:%M:%S.%LZ"

  # set default ordering
  DEFAULT_SORT_ORDER = "event_date_time ASC"
  default_scope order(DEFAULT_SORT_ORDER)

  # Outcomes
  SUCCESS = "success"
  FAILURE = "failure"
  OUTCOMES = [SUCCESS, FAILURE]

  # For rendering "performed by" when no associated user
  SYSTEM = "SYSTEM"

  DULHYDRA_SOFTWARE = "DulHydra #{DulHydra::VERSION}"

  class_attribute :description
  
  validates_presence_of :event_date_time, :pid
  validates :outcome, inclusion: {in: OUTCOMES, message: "\"%{value}\" is not a valid event outcome"}
  validate :object_exists # unless/until we have a deaccession-type of event
 
  after_initialize :set_defaults

  # Repository software version -- e.g., "Fedora Repository 3.7.0"
  def self.repository_software
    @@repository_software ||= ActiveFedora::Base.connection_for_pid(0).repository_profile
                                                .values_at(:repositoryName, :repositoryVersion)
                                                .join(" ")
  end

  # Scopes

  def self.for_object(obj)
    for_pid(obj.pid)
  end

  def self.for_pid(pid)
    where(pid: pid)
  end

  # Rendering methods

  def display_type
    type.sub("Event", "").underscore.gsub(/_/, " ").titleize
  end
  
  def performed_by
    user ? user.to_s : SYSTEM
  end

  def comment_or_summary
    comment.present? ? comment : summary
  end

  # Outcome methods

  def success!
    self.outcome = SUCCESS
  end

  def success?
    outcome == SUCCESS
  end

  def failure!
    self.outcome = FAILURE
  end

  def failure?
    outcome == FAILURE
  end

  # Object getter and setter

  def object
    @object ||= ActiveFedora::Base.find(pid) if pid
  end

  def object=(obj)
    raise ArgumentError, "Can't set to new object" if obj.new_record?
    self.pid = obj.pid
    @object = obj
  end

  # Override pid setter to clear cached object instance variable
  def pid=(pid)
    @object = nil 
    super
  end

  # Return a date/time formatted as a string suitable for use as a PREMIS eventDateTime.
  # Format also works for Solr.
  # Force to UTC.
  def event_date_time_s
    event_date_time.utc.strftime DATE_TIME_FORMAT
  end

  # Return boolean indicator of object existence
  def object_exists?
    !object.nil?
  rescue ActiveFedora::ObjectNotFoundError => e
    false
  end

  protected

  def set_defaults
    self.attributes = defaults.reject { |attr, val| attribute_present? attr }
  end

  def defaults
    { event_date_time: default_event_date_time,
      summary: default_summary,
      software: default_software,
      outcome: default_outcome
    }
  end

  # Validation method
  def object_exists
    unless object_exists?
      errors.add(:pid, "Object \"#{pid}\" does not exist in the repository") 
    end
  end

  def default_software
    DULHYDRA_SOFTWARE
  end

  def default_outcome
    SUCCESS
  end

  def default_summary
    self.class.description
  end

  def default_event_date_time
    Time.now.utc
  end

end
