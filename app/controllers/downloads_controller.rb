class DownloadsController < ApplicationController

  include Hydra::Controller::DownloadBehavior

  def send_content
    datastream.external? ? send_external_content : super
  end

  def send_external_content
    if request.head?
      head :ok,
           content_length: datastream.file_size,
           content_type: datastream.mimeType
    else
      send_file datastream.file_path,
                type: datastream.mimeType,
                filename: datastream_name
    end
  end

  def load_asset
    # XXX Loading instance from solr doesn't work with customized datastream_name (below).
    @asset = ActiveFedora::Base.find(params[asset_param_key])
  end

  def datastream_name
    if datastream.dsid == Ddr::Datastreams::CONTENT
      return asset.original_filename if asset.original_filename.present?
      if asset.identifier.present? # Identifier may be file name minus extension
        identifier = asset.identifier.first
        return [identifier, datastream.default_file_extension].join(".") if identifier =~ /^\w+$/
      end
    end
    datastream.default_file_name
  end

end
