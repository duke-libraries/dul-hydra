class IngestFoldersController < ApplicationController

  before_filter :new_ingest_folder, :only => [:new, :create]

  load_and_authorize_resource

  def new_ingest_folder
    @ingest_folder = IngestFolder.new(ingest_folder_params)
  end

  def new
    # Override default value of 100 to insure that all applicable collections are retrieved
    # for the collection select list
    blacklight_config.configure do |config|
      config.max_per_page = 9999
    end
  end

  def create
    @ingest_folder.user = current_user
    @ingest_folder.model = IngestFolder.default_file_model
    @ingest_folder.add_parents = true
    @ingest_folder.checksum_file = @ingest_folder.checksum_file_location
    @ingest_folder.checksum_type ||= IngestFolder.default_checksum_type
    if @ingest_folder.save
      redirect_to :action => :show, :id => @ingest_folder
    else
      render :new
    end
  end

  def show
    @scan_results = @ingest_folder.scan
  end

  def procezz
    msg = @ingest_folder.procezz
    flash[:notice] = msg
    redirect_to :controller => :batches, :action => :index
  end

  private

  def ingest_folder_params
    params.require(:ingest_folder).permit(:collection_pid, :model, :base_path, :sub_path, :checksum_file, :checksum_type, :add_parents, :parent_id_length)
  end

end
