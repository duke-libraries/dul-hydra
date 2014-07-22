require 'openssl'

module DulHydra
  module HasContent
    extend ActiveSupport::Concern

    included do
      has_file_datastream name: DulHydra::Datastreams::CONTENT, 
                          type: DulHydra::Datastreams::FileContentDatastream,
                          versionable: true, 
                          label: "Content file for this object", 
                          control_group: 'M'

      include Hydra::Derivatives
      include DulHydra::VirusCheckable

      # Original file name of content file should be stored in this property
      has_attributes :original_filename, datastream: DulHydra::Datastreams::PROPERTIES, multiple: false

      before_save :set_original_filename, if: :content_changed?, unless: :original_filename_changed?
      before_save :set_content_type, if: :content_changed?
      around_save :update_thumbnail, if: :content_changed?
    end

    def content_changed?
      content.content_changed?
    end

    # Set content to file and return boolean for changed (true)/not changed (false)
    def upload file
      self.content.content = file
      content_changed?
    end

    # Set content to file and save if changed.
    # Return boolean for success of upload and save.
    def upload! file
      upload(file) && save
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

    def has_content?
      content.has_content?
    end

    def set_thumbnail
      return unless has_content?
      if image? or pdf?
        transform_datastream :content, { thumbnail: { size: "100x100>", datastream: "thumbnail" } }
      end
    end

    def validate_checksum! checksum, checksum_type
      if content_changed?
        raise DulHydra::Error, "Cannot validate checksum against unpersisted content."
      end
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
      unless checksum == content_checksum
        raise DulHydra::ChecksumInvalid, "The checksum provided [#{checksum_type}: #{checksum}] does not match the checksum of the repository content [#{checksum_type}: #{content_checksum}]"
      end
    end

    protected

    def set_original_filename
      file = content.content
      if file.respond_to?(:original_filename)
        self.original_filename = file.original_filename
      elsif file.respond_to?(:path)
        self.original_filename = File.basename(file.path)
      end
    end

    def set_content_type
      file = content.content
      self.content_type = file.content_type if file.respond_to?(:content_type)
    end

    def update_thumbnail
      yield
      set_thumbnail!
    end

  end
end
