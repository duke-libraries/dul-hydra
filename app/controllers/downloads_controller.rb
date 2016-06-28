class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  rescue_from DulHydra::FileNotFound, with: :render_404

  def file_name
    file.original_name || file.default_file_name
  end

  # Overrides Hydra::Controller::DownloadBehavior
  def load_file
    file_path = params[:file] || self.class.default_file_path
    asset.attached_files_having_content.fetch(file_path)
  rescue KeyError
    raise DulHydra::FileNotFound, "#{asset.id}/#{file_path}"
  end
end
