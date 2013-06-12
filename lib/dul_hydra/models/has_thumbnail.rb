module DulHydra::Models
  module HasThumbnail
    extend ActiveSupport::Concern
    
    included do
      has_file_datastream :name => DulHydra::Datastreams::THUMBNAIL, :type => DulHydra::Datastreams::FileContentDatastream,
                          :versionable => true, :label => "Thumbnail for this object", :control_group => 'M'
    end

  end  
end
