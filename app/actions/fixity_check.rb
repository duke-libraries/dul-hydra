class FixityCheck

  attr_reader :object

  # Datastream checksum validation outcomes
  VALID = "VALID"
  INVALID = "INVALID"

  DETAIL_PREAMBLE = "Datastream checksum validation results:"
  DETAIL_TEMPLATE = "%{dsid} ... %{validation}"

  def initialize(object)
    @object = object
  end

  # Returns a FixityCheckEvent for the object
  def execute
    date_time = Time.now.utc
    success = true
    results = {}
    object.datastreams.select { |dsid, ds| ds.has_content? }.each do |dsid, ds|
      success &&= ds.dsChecksumValid
      results[dsid] = ds.profile
    end
    FixityCheckEvent.new.tap do |e|
      e.object = object
      e.event_date_time = date_time
      e.failure! unless success
      detail = [DETAIL_PREAMBLE]
      results.each do |dsid, dsProfile|
        validation = dsProfile["dsChecksumValid"] ? VALID : INVALID
        detail << DETAIL_TEMPLATE % {dsid: dsid, validation: validation} 
      end
      e.detail = detail.join("\n")
    end    
  end

  # Returns a persisted FixityCheckEvent for the object
  def execute!
    event = execute
    event.save! && event
  end

  def self.execute(object)
    new(object).execute
  end

  def self.execute!(object)
    new(object).execute!
  end

end
