require "mime/types"
require "fileutils"

class DuracloudFileSerialization

  FILE_DESC    = "file-desc.rdf"
  FILE_CONTENT = "file-content"
  FILE_DIGEST  = "file-sha1.txt"

  def self.serialize(file, dir)
    new(file, dir).serialize
  end

  attr_reader :file, :dir

  def initialize(file, dir)
    @file, @dir = file, dir
  end

  def serialize
    FileUtils.mkdir_p(dir)
    FileUtils.cd(dir) { do_serialize }
    dir
  end

  private

  def do_serialize
    write_description
    write_content_or_digest
  end

  def write_description
    File.open("file-desc.rdf", "wb") do |f|
      description = file.metadata.ldp_source.graph.dump(:rdfxml)
      f.write(description)
    end
  end

  def write_content_or_digest
    file.size < 4096 ? write_content : write_digest
  end

  def write_content
    file_name = [FILE_CONTENT, file_extension].join(".")
    File.open(file_name, "wb", encoding: Encoding::ASCII_8BIT) do |f|
      f.write(file.content)
    end
  end

  def write_digest
    File.open(FILE_DIGEST, "wb") do |f|
      f.write(file.checksum.value)
    end
  end

  def file_extension
    ext = nil
    media_type = file.mime_type || "application/octet-stream"
    if mime_type = MIME::Types[media_type].first
      ext = mime_type.extensions.first
    end
    ext || "bin"
  end
end
