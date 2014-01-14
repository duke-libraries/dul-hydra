module DulHydra
  module HasThumbnail
    extend ActiveSupport::Concern
    
    included do
      has_file_datastream :name => DulHydra::Datastreams::THUMBNAIL, 
                          :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, 
                          :label => "Thumbnail for this object", 
                          :control_group => 'M'
    end

    def generate_thumbnail(source, args={})
      DulHydra::Derivatives::Thumbnail.new(source, args)
    end

    def generate_thumbnail!(source, args={})
      datastreams[DulHydra::Datastreams::THUMBNAIL].content = generate_thumbnail(source, args)
    end

    def generate_content_thumbnail(args={})
      generate_thumbnail(datastreams[DulHydra::Datastreams::CONTENT], args)
    end

    def generate_content_thumbnail!(args={})
      generate_thumbnail!(datastreams[DulHydra::Datastreams::CONTENT], args)
    end

  end  
end
