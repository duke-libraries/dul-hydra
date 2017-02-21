class FixityCheck

  def self.call(repo_object)
    Ddr::Events::FixityCheckEvent.create(pid: repo_object.id) do |event|
      checks = execute(repo_object)
      event.failure! unless checks.values.all?
      detail = checks.map do |file_id, success|
        [ file_id, success.to_s ].join(": ")
      end
      event.detail = detail.join("\n")
    end
  end

  def self.execute(repo_object)
    Hash.new.tap do |checks|
      repo_object.attached_files_having_content.each do |file_id, repo_file|
        checks[file_id] = check_file(repo_file)
      end
    end
  end

  def self.check_file(repo_file)
    if repo_file.external?
      check_external_file(repo_file)
    else
      repo_file.dsChecksumValid
    end
  end

  def self.check_external_file(repo_file)
    stored_digest = FileDigest.find_by_repo_id_and_file_id!(repo_file.pid, repo_file.dsid)
    file_path = repo_file.respond_to?(:file_path) ? repo_file.file_path : Ddr::Utils.path_from_uri(repo_file.dsLocation)
    stored_digest.sha1 == FileDigest.generate_sha1(file_path)
  end

end
