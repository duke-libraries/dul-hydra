class FileDigestManager

  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    repo_id, file_id, profile = event.payload.values_at(:pid, :file_id, :profile)
    case event.name
    when Ddr::Datastreams::SAVE
      if profile && profile["dsControlGroup"] == "E"
        file_path = Ddr::Utils.path_from_uri(profile["dsLocation"])
        add_or_update(repo_id, file_id, file_path)
      end
    when Ddr::Datastreams::DELETE
      delete(repo_id, file_id)
    when Ddr::Models::Base::DELETE
      delete(repo_id)
    else
      raise ArgumentError, "#{self.class} does not handle event name \"#{event.name}\"."
    end
  end

  def self.add_or_update(repo_id, file_id, file_path)
    file_digest = FileDigest.find_or_initialize_by(repo_id: repo_id, file_id: file_id)
    file_digest.path = file_path
    file_digest.set_digests
    file_digest.save!
  end

  def self.delete(repo_id, file_id = nil)
    conditions = { repo_id: repo_id }
    conditions.merge!(file_id: file_id) if file_id
    FileDigest.where(conditions).destroy_all
  end

end
