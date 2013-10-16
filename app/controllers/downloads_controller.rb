class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def show
    authorize! :download, datastream
    send_content(asset)
  end

  def datastream_name
    case
    when asset.source.present?
      asset.source.first
    when asset.identifier.present?
      asset.identifier.first
    else
      asset.safe_pid
    end
  end

end
