require 'digest'

module ExportFiles
  class PayloadFile

    attr_reader :object, :datastream
    alias_method :file, :datastream # looking forward to PCDM terminology

    delegate :content, to: :datastream
    delegate :original_filename, to: :object

    def initialize(object, datastream)
      @object = object
      @datastream = datastream
    end

    def to_s
      "object #{repo_id}, datastream #{file_id}"
    end

    ContentDigest = Struct.new(:type, :value)

    def content_digest
      @content_digest ||=
        if datastream.external?
          stored_digest = FileDigest.find_by_repo_id_and_file_id!(repo_id, file_id)
          ContentDigest.new(Digest::SHA1, stored_digest.sha1)
        else
          algorithm = datastream.checksumType
          klass = Digest.const_get(algorithm.sub("-", ""))
          ContentDigest.new(klass, datastream.checksum)
        end
    end

    def file_id
      datastream.dsid
    end

    def repo_id
      object.id
    end

    def source_path
      if datastream.external?
        datastream.file_path
      end
    end

    def parent
      if object.respond_to?(:parent)
        object.parent
      end
    end

    def default_filename
      datastream.default_file_name
    end

    def master_file?
      file_id == Ddr::Datastreams::CONTENT
    end

  end
end
