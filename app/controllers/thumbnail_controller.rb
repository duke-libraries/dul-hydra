class ThumbnailController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def datastream_name
    "#{asset.pid.sub(/:/, "-")}-thumbnail"
  end

  def datastream_to_show
    asset.datastreams[DulHydra::Datastreams::THUMBNAIL]
  end  

end
