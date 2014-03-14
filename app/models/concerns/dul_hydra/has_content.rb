require 'digest'

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
    # If checksum param is a non-empty string, it must match the SHA-256 digest for the file,
    # or the upload will raise an exception (DulHydra::ChecksumInvalid).
    def upload file, checksum = nil
      validate_checksum! file, checksum unless checksum.blank?
      self.content.content = file
      content_changed?
    end

    # Set content to file and save if changed
    def upload! file, checksum = nil
      upload(file, checksum) && save
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

    def to_solr(solr_doc=Hash.new, opts={})
      solr_doc = super(solr_doc, opts)
      solr_doc.merge!(DulHydra::IndexFields::ORIGINAL_FILENAME => original_filename)
      solr_doc
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

    private 

    def validate_checksum! file, checksum
      digest = Digest::SHA256.new
      digest << file.read
      unless digest.to_s == checksum
        raise DulHydra::ChecksumInvalid, "The checksum provided [#{checksum}] does not match the content digest [#{digest.to_s}]"
      end
    ensure
      file.rewind
    end

  end
end
