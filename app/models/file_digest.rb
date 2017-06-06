require 'digest'

class FileDigest < ActiveRecord::Base

  validates_presence_of :repo_id, :file_id, :path

  def self.generate_sha1(path)
    Digest::SHA1.file(path).hexdigest
  end

  def self.generate_md5(path)
    Digest::MD5.file(path).hexdigest
  end

  delegate :generate_sha1, :generate_md5, to: :class

  def set_digests
    self.sha1 = generate_sha1(path)
    self.md5  = generate_md5(path)
  end

end
