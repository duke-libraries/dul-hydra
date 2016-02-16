class ThumbnailController < ApplicationController

  include Hydra::Controller::DownloadBehavior

  def datastream_name
    "#{asset.id.sub(/:/, "-")}-thumbnail"
  end

  def load_file
    asset.attached_files[Ddr::Models::File::THUMBNAIL]
  end

end
