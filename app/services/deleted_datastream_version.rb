class DeletedDatastreamVersion

  def self.call(repo_id, file_id, profile)
    case profile["dsControlGroup"]
    when "M"
      managed(repo_id, file_id, profile)
    when "E"
      external(repo_id, file_id, profile)
    else
      false
    end
  end

  def self.managed(repo_id, file_id, profile)
    DeletedFile.create(repo_id: repo_id,
                       file_id: file_id,
                       version_id: profile["dsVersionID"],
                       source: DeletedFile::F3_DS_MANAGED,
                       last_modified: profile["dsCreateDate"])
  end

  def self.external(repo_id, file_id, profile)
    return false unless profile["dsLocation"].start_with?("file:")
    path = Ddr::Utils.path_from_uri(profile["dsLocation"])
    DeletedFile.create(repo_id: repo_id,
                       file_id: file_id,
                       version_id: profile["dsVersionID"],
                       source: DeletedFile::F3_DS_EXTERNAL,
                       path: path,
                       last_modified: profile["dsCreateDate"])
  end

end
