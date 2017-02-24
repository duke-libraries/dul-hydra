class DeletedDatastream

  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    payload = event.payload
    payload[:version_history].each do |profile|
      DeletedDatastreamVersion.call(payload[:pid], payload[:file_id], profile)
    end
  end

end
