class VirusCheck

  attr_reader :object, :file

  DETAIL_TEMPLATE = <<-EOS
File: %{file}
Scan Result: %{result}
  EOS
  
  def initialize(object, file)
    @object = object
    @file = file
  end

  # Return a VirusCheckEvent for the scan result
  def execute
    result = DulHydra::Services::Antivirus.scan(file)
    VirusCheckEvent.new.tap do |e|
      e.object = object unless object.new_record?
      e.failure! unless result.ok? 
      e.event_date_time = result.scanned_at
      e.detail = DETAIL_TEMPLATE % {
        file: File.basename(result.file), 
        result: result.status
      }
      e.software = result.version
    end
  end

  # Return a VirusCheckEvent for the scan result
  def self.execute(object, file)
    new(object, file).execute
  end

end
