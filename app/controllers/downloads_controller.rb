class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def show
    authorize! :download, datastream
    send_content(asset)
  end

  def load_asset
    @asset = ActiveFedora::Base.find(params[asset_param_key], cast: true)
  end

  def datastream_name
    if datastream.dsid == DulHydra::Datastreams::CONTENT
      return asset.original_filename if asset.original_filename.present?
      if asset.identifier.present? # Identifier may be file name minus extension
        identifier = asset.identifier.first
        return [identifier, datastream.default_file_extension].join(".") if identifier =~ /^\w+$/
      end
    end
    datastream.default_file_name
  end

end
