class DownloadsController < ApplicationController

  include Hydra::Controller::DownloadBehavior

  def load_asset
    # XXX Loading instance from solr doesn't work with customized datastream_name (below).
    @asset = ActiveFedora::Base.find(params[asset_param_key])
  end

  def datastream_name
    if datastream.dsid == Ddr::Models::File::CONTENT
      return asset.original_filename if asset.original_filename.present?
      if asset.identifier.present? # Identifier may be file name minus extension
        identifier = asset.identifier.first
        return [identifier, datastream.default_file_extension].join(".") if identifier =~ /^\w+$/
      end
    end
    datastream.default_file_name
  end

end
