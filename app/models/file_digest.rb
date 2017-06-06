require 'digest'

class FileDigest < ActiveRecord::Base

  validates_presence_of :repo_id, :file_id, :sha1

  def self.sha1(repo_id, file_id)
    if fd = find_by(repo_id: repo_id, file_id: file_id)
      fd.sha1
    end
  end

  def self.generate_sha1(path)
    Digest::SHA1.file(path).hexdigest
  end

  delegate :generate_sha1, to: :class

  def set_digest(path)
    self.sha1 = generate_sha1(path)
  end

end
