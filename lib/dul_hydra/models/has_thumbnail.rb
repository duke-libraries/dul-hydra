require 'fileutils'
require 'RMagick'

module DulHydra::Models
  module HasThumbnail
    extend ActiveSupport::Concern

    DEFAULT_SIZE = 100
    DEFAULT_PRESERVE_ASPECT_RATIO = true
    DEFAULT_SOURCE_DATASTREAM = DulHydra::Datastreams::CONTENT
    DEFAULT_THUMBNAIL_FORMAT = "jpeg"
    
    included do
      has_file_datastream :name => DulHydra::Datastreams::THUMBNAIL, :type => DulHydra::Datastreams::FileContentDatastream
    end

    def generate_thumbnail(
                           cols=DEFAULT_SIZE,
                           rows=nil,
                           preserve_aspect_ratio=DEFAULT_PRESERVE_ASPECT_RATIO,
                           thumbnail_format = DEFAULT_THUMBNAIL_FORMAT,
                           source_datastream=DEFAULT_SOURCE_DATASTREAM
                          )
      rows ||= cols
      source_image = Magick::Image.from_blob(self.datastreams[source_datastream].content).first
      thumbnail = case preserve_aspect_ratio
      when true
        source_image.change_geometry(Magick::Geometry.new(cols, rows)) do |cols, rows, img|
          img.resize(cols,rows)
        end
      when false
        source_image.resize(cols, rows)
      end
      thumbnail.format = thumbnail_format
      return thumbnail
    end
    
    def generate_thumbnail!(
                            cols=DEFAULT_SIZE,
                            rows=nil,
                            preserve_aspect_ratio=DEFAULT_PRESERVE_ASPECT_RATIO,
                            thumbnail_format = DEFAULT_THUMBNAIL_FORMAT,
                            source_datastream=DEFAULT_SOURCE_DATASTREAM
                            )
      thumbnail = self.generate_thumbnail(cols, rows, preserve_aspect_ratio, thumbnail_format, source_datastream)
      tmp_dir = Dir.mktmpdir("dul_hydra_thumbnail")
      tmp_file = "#{tmp_dir}/thumbnail.#{DEFAULT_THUMBNAIL_FORMAT}"
      thumbnail.write(tmp_file)
      file = File.open(tmp_file)
      self.thumbnail.content_file = file
      self.save
      file.close
      FileUtils.remove_dir(tmp_dir)
    end
  end
  
end