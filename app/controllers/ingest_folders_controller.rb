class IngestFoldersController < ApplicationController
  
  load_resource

  def new
  end
  
  def create
    @ingest_folder = IngestFolder.new(params[:ingest_folder])
    @ingest_folder.username = current_user.username
    @ingest_folder.save
    redirect_to :action => :show, :id => @ingest_folder
  end
  
  def show
    results = @ingest_folder.scan
    @included = results[0]
    @excluded = results[1]
  end
  
  def procezz
    @ingest_folder.procezz
    redirect_to :controller => :batches, :action => :index
  end
    
end