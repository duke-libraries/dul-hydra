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

  validates_presence_of :event_date_time, :pid, :software
  validates :outcome, inclusion: {in: OUTCOMES, message: "\"%{value}\" is not a valid event outcome"}
  validate :object_exists # unless/until we have a deaccession-type of event
 
  before_validation :set_defaults

  # Factories

  def self.create_event(type, args={})
    event = build_event(type, args)
    event.save!
    event
  end

  def self.build_event(type, args={})
    begin
      klass = "#{type.to_s.camelize}Event".constantize
    rescue NameError
      raise ArgumentError, "\"#{type.to_s}\" does not correspond to a valid event type"
    end
    object = args.delete(:object)
    klass.new.tap do |event|
      event.object = object if object
      event.attributes = args
      yield event if block_given?
    end
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
    self.attributes = defaults.reject { |key, val| attribute_present? key }
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

  def repository_software
    if object_exists?
      repo = object.inner_object.repository.repository_profile
      "#{repo[:repositoryName]} #{repo[:repositoryVersion]}"
    end  
  end

  def dulhydra_software
    "DulHydra #{DulHydra::VERSION}"
  end

  def default_software
    dulhydra_software
  end

  def default_outcome
    SUCCESS
  end

  def default_event_date_time
    Time.now.utc
  end

  def default_summary
    nil
  end

end
