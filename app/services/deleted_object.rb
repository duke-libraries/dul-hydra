class DeletedObject

  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    payload = event.payload
    repo_id = payload[:pid]
    DeletedFile.create(repo_id: repo_id,
                       source: DeletedFile::FOXML,
                       last_modified: payload[:modified_date])
    payload[:datastream_history].each do |file_id, version_history|
      version_history.each do |profile|
        DeletedDatastreamVersion.call(repo_id, file_id, profile)
      end
    end
  end

end
