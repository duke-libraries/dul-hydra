require 'mime/types'

module DulHydra::Derivatives
  class Image

    EXTRA_IMAGE_TYPES = ["application/pdf"]

    attr_accessor :derivative
    delegate :[], :write, :path, :content_type, :to => :derivative

    # Returns an image derived from the source.
    # The source can be an IO object, datastream (anything that responds to :read)
    # or a file path (String)
    def initialize(source, opts={})
      if source.is_a?(IO)
        image = MiniMagick::Image.read(source)
      elsif source.is_a?(ActiveFedora::Datastream)
        if valid_content_type?(source.mimeType)
          image = MiniMagick::Image.read(source.read)
        else
          raise DulHydra::Error, "Datastream content is not an image."
        end
      elsif source.is_a?(String)
        if source.size > 1024
          raise DulHydra::Error, "String too large! Do not pass binary content to this method."
        end
        if File.exists?(source)
          content_type = MIME::Types.type_for(source).first.to_s rescue nil
          if valid_content_type?(content_type)
            image = MiniMagick::Image.open(source)
          else
            raise DulHydra::Error, "The file is not an image or unable to determine content type."
          end
        else
          raise DulHydra::Error, "File not found at path specified."
        end
      else
        raise DulHydra::Error, "Not a valid source for image derivative generation."
      end
      if opts.has_key?(:height) || opts.has_key?(:width)
        height = opts[:height] || opts[:width]
        width = opts[:width] || opts[:height]
        size = "#{height}x#{width}"
        # Do not preserve aspect ratio if :height and :width are explicitly set options
        size << "!" if opts.has_key?(:height) && opts.has_key?(:width)
        image.resize size
      end
      image.format opts[:format] if opts[:format]
      @derivative = image
    end

    def read
      derivative.to_blob
    end

    def self.thumbnail(source, opts={})
      defaults = {height: 100, format: "PNG"}
      opts.merge!(defaults) { |key, opt, default| opt }
      new(source, opts)
    end

    private

    def valid_content_type?(content_type)
      return false if content_type.blank?
      content_type.start_with?("image/") || EXTRA_IMAGE_TYPES.include?(content_type)
    end

  end
end
