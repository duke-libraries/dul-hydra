class FixityCheck

  # Return result of fixity check - wrapped by a notifier
  def self.execute(object)
    ActiveSupport::Notifications.instrument(DulHydra::Notifications::FIXITY_CHECK) do |payload|
      payload[:result] = _execute(object)
    end
  end

  # Return result of fixity check
  def self._execute(object)
    Result.new(pid: object.pid).tap do |r|
      object.datastreams_to_validate.each do |dsid, ds|
        r.success &&= ds.dsChecksumValid
        r.results[dsid] = ds.profile
      end
    end
  end

  class Result
    attr_accessor :pid, :success, :results, :checked_at

    def initialize(args={})
      @pid = args[:pid]
      @success = args[:success] || true
      @results = args[:results] || {}
      @checked_at = args[:checked_at] || Time.now.utc
    end
  end

end
