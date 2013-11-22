class IngestFoldersController < ApplicationController
  
  load_and_authorize_resource

  def new
    @admin_policies = AdminPolicy.all
    collections = Collection.all
    collection_hash = {}
    collections.each { |coll| collection_hash[coll.title.first] = coll.pid }
    @collection_options = Hash[collection_hash.sort]
    @permitted_folder_bases = IngestFolder.permitted_folders(current_user)
  end
  
  def create
    @admin_policies = AdminPolicy.all
    collections = Collection.all
    collection_hash = {}
    collections.each { |coll| collection_hash[coll.title.first] = coll.pid }
    @collection_options = Hash[collection_hash.sort]
    @permitted_folder_bases = IngestFolder.permitted_folders(current_user)
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
    @collection_title = Collection.find(@ingest_folder.collection_pid).title.first if @ingest_folder.collection_pid.present?
    @scan_results = @ingest_folder.scan
  end
  
  def procezz
    @ingest_folder.procezz
    redirect_to :controller => :batches, :action => :index
  end
    
end