class DownloadsController < ApplicationController

  include Hydra::Controller::DownloadBehavior
  include DulHydra::Controller::DownloadBehavior

  def load_asset
    # XXX Loading instance from solr doesn't work with customized datastream_name (below).
    @asset = ActiveFedora::Base.find(params[asset_param_key])
  end

  def datastream_name
    if datastream.external?
      file_path = DulHydra::Utils.path_from_uri(datastream.dsLocation)
      return File.basename(file_path)
    elsif datastream.dsid == DulHydra::Datastreams::DESC_METADATA
      return "#{datastream.default_file_prefix}.txt"
    elsif datastream.dsid == DulHydra::Datastreams::CONTENT
      return asset.original_filename if asset.original_filename.present?
      if asset.identifier.present? # Identifier may be file name minus extension
        identifier = asset.identifier.first
        return [identifier, datastream.default_file_extension].join(".") if identifier =~ /^\w+$/
      end
    end
    datastream.default_file_name
  end

end
