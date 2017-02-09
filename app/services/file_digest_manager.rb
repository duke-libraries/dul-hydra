class FileDigestManager

  def self.call(*args)
    event = ActiveSupport::Notifications::Event.new(*args)
    repo_id, file_id, profile = event.payload.values_at(:pid, :file_id, :profile)
    case event.name
    when Ddr::Datastreams::SAVE
      if profile && profile["dsControlGroup"] == "E"
        add_or_update(repo_id, file_id, profile["dsLocation"])
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
    file_digest.sha1 = FileDigest.sha1(file_path)
    if file_digest.sha1_changed?
      file_digest.save
    else
      false
    end
  end

  def self.delete(repo_id, file_id = nil)
    if file_id
      if file_digest = FileDigest.find_by_repo_id_and_file_id(repo_id, file_id)
        file_digest.destroy
      end
    else
      FileDigest.where(repo_id: repo_id).destroy_all
    end
  end

end
