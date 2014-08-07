require 'openssl'

module DulHydra
  module HasContent
    extend ActiveSupport::Concern

    included do
      has_file_datastream name: DulHydra::Datastreams::CONTENT,
                          versionable: true, 
                          label: "Content file for this object",
                          control_group: "E"

      include Hydra::Derivatives

      around_save :update_thumbnail, if: :external_file_changed?
      delegate :has_content?, to: :content
    end

    def original_filename
      content.external? ? content.file_name : properties.original_filename.first
    end

    # Set content to file and return boolean for changed (true)/not changed (false)
    def upload file, opts={}
      add_file(file, DulHydra::Datastreams::CONTENT, opts)
    end

    # Set content to file and save if changed.
    # Return boolean for success of upload and save.
    def upload! file, opts={}
      upload(file, opts)
      save
    end

    def content_type
      content.mimeType
    end

    def content_type= mime_type
      self.content.mimeType = mime_type
    end

    def image?
      content_type =~ /image\//
    end

    def pdf?
      content_type == "application/pdf"
    end

    def set_thumbnail
      return unless has_content?
      if image? or pdf?
        transform_datastream :content, { thumbnail: { size: "100x100>", datastream: "thumbnail" } }
      end
    end

    def validate_checksum! checksum, checksum_type
      raise DulHydra::Error, "Checksum cannot be validated on unpersisted object." if new_record?
      if content.checksumType == checksum_type
        content_checksum = content.checksum
      else
        begin
          digest_class = OpenSSL::Digest.const_get(checksum_type.sub("-", "").to_sym)
          digest = digest_class.new
          digest << content.content
          content_checksum = digest.to_s
        rescue NameError => e
          raise ArgumentError, "Checksum type not recognized: #{checksum_type.inspect}"
        end
      end
      if checksum == content_checksum
        "The checksum [#{checksum_type}: #{checksum}] is valid for the content of #{model_pid}."
      else
        raise DulHydra::ChecksumInvalid, "The checksum [#{checksum_type}: #{checksum}] does not match repository checksum [#{checksum_type}: #{content_checksum}] for the content of #{model_pid}."
      end
    end

    def virus_checks
      VirusCheckEvent.for_object(self)
    end

    protected

    def external_file_changed?
      content.dsLocation_changed?
    end

    def update_thumbnail
      yield
      set_thumbnail!
    end

    def default_content_type
      "application/octet-stream"
    end

  end
end
