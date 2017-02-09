require 'digest'

class FileDigest < ActiveRecord::Base

  validates_presence_of :repo_id, :file_id, :sha1

  def self.sha1(file_path)
    path = file_path.sub(/\Afile:/, "")
    Digest::SHA1.file(path).hexdigest
  end

end
