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
    end

    delegate :content_changed?, to: :content

    def upload file
      set_content file
      set_original_filename file
      set_content_type file
    end

    def set_content file
      self.content.content = file
    end

    def content_type
      content.mimeType
    end

    def content_type= mime_type
      self.content.mimeType = mime_type
    end

    def set_thumbnail
      set_thumbnail_from_content
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

    protected

    def set_original_filename file
      if file.respond_to?(:original_filename)
        self.original_filename = file.original_filename
      elsif file.respond_to?(:path)
        self.original_filename = File.basename(file.path)
      end
    end

    def set_content_type file
      if file.respond_to?(:content_type)
        self.content_type = file.content_type
      end
    end

  end
end
