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

      around_save :update_thumbnail, if: :content_changed?

      delegate :validate_checksum!, to: :content
    end

    def original_filename
      # The fallback is here in case we don't convert all content datastreams from managed to external
      content.external? ? content.file_name : properties.original_filename.first
    end

    # Convenience method wrapping FileManagement#add_file
    def upload file, opts={}
      add_file(file, DulHydra::Datastreams::CONTENT, opts)
    end

    # Set content to file and save
    def upload! file, opts={}
      upload(file, opts)
      save
    end

    def content_size
      content.external? ? content.file_size : content.dsSize
    end

    def content_human_size
      ActiveSupport::NumberHelper.number_to_human_size(content_size) if content_size
    end

    def content_type
      content.mimeType
    end

    def content_major_type
      content_type.split("/").first
    end

    def content_sub_type
      content_type.split("/").last
    end

    def content_type= mime_type
      self.content.mimeType = mime_type
    end

    def image?
      content_major_type == "image"
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

    def virus_checks
      VirusCheckEvent.for_object(self)
    end

    def content_changed?
      content.dsLocation_changed?
    end

    protected

    def update_thumbnail
      yield
      set_thumbnail!
    end

    def default_content_type
      "application/octet-stream"
    end

  end
end
