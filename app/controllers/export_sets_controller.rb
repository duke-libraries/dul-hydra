class ExportSetsController < ApplicationController
  
  include Blacklight::Catalog

  before_filter :enforce_read_permissions, :only => [:show, :new]

  def index
    @export_sets = ExportSet.where(:user_id => current_user)
  end
  
  def show
    @export_set = ExportSet.find(params[:id])
    @response, @documents = get_solr_response_for_field_values(SolrDocument.unique_key, @export_set.pids)
  end
  
  def new
    @export_set = ExportSet.new
    bookmark_ids = current_user.bookmarks.collect { |b| b.document_id.to_s }
    @response, @documents = get_solr_response_for_field_values(SolrDocument.unique_key, bookmark_ids)
    @documents.keep_if { |doc| doc.has_content? }
  end
  
  def create
    @export_set = ExportSet.new(params[:export_set])
    @export_set.user = current_user
    @export_set.create_archive # saves
    flash[:notice] = "Export Set created."
    redirect_to :action => :show, :id => @export_set
  end

  def edit
    @export_set = ExportSet.find(params[:id])
  end

  def update
    @export_set = ExportSet.find(params[:id])
    @export_set.update_attributes(params[:export_set])
    flash[:notice] = "Export Set updated."
    redirect_to :action => :show, :id => @export_set
  end
  
  def destroy
    @export_set = ExportSet.find(params[:id])
    @export_set.destroy
    flash[:notice] = "Export Set destroyed."
    redirect_to :action => 'index'
  end

  def archive
    @export_set = ExportSet.find(params[:id])
    if request.delete?
      unless @export_set.archive_file_name.nil?
        @export_set.archive = nil
        @export_set.save
        flash[:notice] = "Archive deleted."
      end
    elsif request.post?
      if @export_set.archive_file_name.nil?
        @export_set.create_archive
        flash[:notice] = "Archive created."
      end
    end
    redirect_to :action => :show, :id => @export_set
  end

  protected

  def enforce_read_permissions
    discovery_permissions = ["read", "edit"]
  end
  
end
