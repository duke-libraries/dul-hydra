class FixityCheck

  Result = Struct.new(:pid, :success, :results, :checked_at)

  # Return result of fixity check - wrapped by a notifier
  def self.execute(object)
    ActiveSupport::Notifications.instrument(DulHydra::Notifications::FIXITY_CHECK) do |payload|
      payload[:result] = _execute(object)
    end
  end

  # Return result of fixity check
  def self._execute(object)
    Result.new.tap do |r|
      r.pid = object.pid
      r.success = true
      r.results = {}
      r.checked_at = Time.now.utc
      object.datastreams_to_validate.each do |dsid, ds|
        r.success &&= ds.dsChecksumValid
        r.results[dsid] = ds.profile
      end
    end
  end

end
