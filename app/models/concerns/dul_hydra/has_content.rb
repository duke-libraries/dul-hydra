module DulHydra
  module HasContent
    extend ActiveSupport::Concern

    included do
      has_file_datastream :name => DulHydra::Datastreams::CONTENT, 
                          :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, 
                          :label => "Content file for this object", 
                          :control_group => 'M'

      include Hydra::Derivatives
    end

    def content_type
      self.content.mimeType
    end

    def set_thumbnail
      set_thumbnail_from_content
    end

    def terms_for_editing
      terms = super
      terms.delete(:source) # source is reserved for original file name
      terms
    end

    def set_content(str_or_io)
      self.content.content = str_or_io
      self.source = str_or_io.original_filename if str_or_io.respond_to?(:original_filename)
    end
      
  end
end
