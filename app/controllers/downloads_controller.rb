class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def datastream_name
    case
    when !asset.source.blank?
      asset.source.first
    when !asset.identifier.blank?
      asset.identifier.first
    else
      asset.pid.sub(/:/, "-")
    end
  end

end
