class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  def show
    authorize! :download, datastream
    send_content(asset)
  end

  def datastream_name
    if datastream.is_a? DulHydra::Datastreams::FileContentDatastream
      if asset.describable?
        if asset.source.present? # Source may be "original" file name
          source = asset.source.first
          return source if source =~ /^\w+\.\w+$/
        end
        if asset.identifier.present? # Identifier may be file name minus extension
          identifier = asset.identifier.first
          return [identifier, datastream.default_file_extension].join(".") if identifier =~ /^\w+$/
        end
      end
    end
    datastream.default_file_name
  end

end
