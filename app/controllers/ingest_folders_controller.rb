class IngestFoldersController < ApplicationController
  
  load_and_authorize_resource

  def new
    @admin_policies = AdminPolicy.all
    @models = IngestFolder.default_models
    @permitted_folder_bases = IngestFolder.permitted_folders(current_user)
  end
  
  def create
    @ingest_folder = IngestFolder.new(params[:ingest_folder])
    @ingest_folder.user = current_user
    @ingest_folder.save
    redirect_to :action => :show, :id => @ingest_folder
  end
  
  def show
    @included, @excluded = @ingest_folder.scan
  end
  
  def procezz
    @ingest_folder.procezz
    redirect_to :controller => :batches, :action => :index
  end
    
end