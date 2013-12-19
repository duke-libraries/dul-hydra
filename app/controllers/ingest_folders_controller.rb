class IngestFoldersController < ApplicationController
  
  load_and_authorize_resource

  def new
  end
  
  def create
    @ingest_folder = IngestFolder.new(params[:ingest_folder])
    @ingest_folder.user = current_user
    @ingest_folder.model = IngestFolder.default_file_model
    @ingest_folder.add_parents = true
    @ingest_folder.checksum_file = @ingest_folder.checksum_file_location
    @ingest_folder.checksum_type = IngestFolder.default_checksum_type
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
    @ingest_folder.procezz
    redirect_to :controller => :batches, :action => :index
  end
    
end