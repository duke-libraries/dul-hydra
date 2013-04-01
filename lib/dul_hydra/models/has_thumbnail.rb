require 'fileutils'

module DulHydra::Models
  module HasThumbnail
    extend ActiveSupport::Concern

    DEFAULT_THUMBNAIL_SIZE = 100
    DEFAULT_PRESERVE_ASPECT_RATIO = true
    DEFAULT_THUMBNAIL_SOURCE_DSID = DulHydra::Datastreams::CONTENT
    DEFAULT_THUMBNAIL_FORMAT = "PNG"
    
    included do
      has_file_datastream :name => DulHydra::Datastreams::THUMBNAIL, :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, :label => "Thumbnail for this object", :control_group => 'M'
    end

    def has_thumbnail?
      !datastreams[DulHydra::Datastreams::THUMBNAIL].profile.empty?
    end

    def generate_thumbnail( opts={} )
      cols = opts.fetch(:cols, DEFAULT_THUMBNAIL_SIZE)
      rows = opts.fetch(:rows, cols)
      preserve_aspect_ratio = opts.fetch(:preserve_aspect_ratio, DEFAULT_PRESERVE_ASPECT_RATIO)
      format = opts.fetch(:format, DEFAULT_THUMBNAIL_FORMAT)
      dsid = opts.fetch(:dsid, DEFAULT_THUMBNAIL_SOURCE_DSID)      
      thumbnail = nil
      mimetype = self.datastreams[dsid].mimeType
      if mimetype.start_with?("image") || mimetype.end_with?("pdf")
        image = MiniMagick::Image.read(self.datastreams[dsid].content)
        geometry = "#{cols}x#{rows}"
        geometry << "!" unless preserve_aspect_ratio
        image.thumbnail geometry
        image.format format
        thumbnail = image
      end
      return thumbnail
    end
    
    def generate_thumbnail!( opts={} )
      thumbnail = self.generate_thumbnail( opts )
      if !thumbnail.nil?
        Dir.mktmpdir("dul_hydra_thumbnail") do |tmp_dir|
          tmp_file = "#{tmp_dir}/thumbnail.#{opts.fetch(:format, DEFAULT_THUMBNAIL_FORMAT)}"
          thumbnail.write(tmp_file)
          File.open(tmp_file) do |file|
            self.thumbnail.content_file = file
            self.save
          end
        end
      end
      return thumbnail
    end
  end
  
end
