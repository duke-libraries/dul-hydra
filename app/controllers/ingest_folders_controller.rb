class IngestFoldersController < ApplicationController
  respond_to :html
  
  def new
    @ingest_folder = IngestFolder.new
  end
  
  def create
    collection = params[:collection_pid] ? Collection.find(params[:collection_pid]) : nil
    admin_policy = params[:admin_policy_pid] ? AdminPolicy.find(params[:admin_policy_pid]) : nil
    @ingest_folder = IngestFolder.new(
      :dirpath => params[:dirpath],
      :user => current_user,
      :collection => collection,
      :admin_policy => admin_policy,
      :model => params[:model]
    )
    respond_with @ingest_folder, location: ingest_folders_show_path
  end
  
  def show
  end
    
end