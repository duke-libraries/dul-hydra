class ExportSetsController < ApplicationController
  
  include Blacklight::Catalog
  
  def index
    # XXX authz
    @export_sets = ExportSet.where(:user_id => current_user)
    if @export_sets.empty?
      flash[:notice] = "You have no export sets."
    end
  end
  
  def show
    # XXX authz
    @export_set = ExportSet.find(params[:id])
    @response, @document_list = get_solr_response_for_field_values(SolrDocument.unique_key, @export_set.pids)
  end
  
  def new
    # XXX authz
    @export_set = ExportSet.new
    bookmark_ids = current_user.bookmarks.collect { |b| b.document_id.to_s }
    @response, @document_list = get_solr_response_for_field_values(SolrDocument.unique_key, bookmark_ids)
    @document_list.keep_if { |doc| doc.has_content? }
    if @document_list.empty?
      flash[:notice] = "You have no bookmarks for content-bearing objects."
    end
  end
  
  def create
    # XXX authz
    @export_set = ExportSet.new(params[:export_set])
    @export_set.user = current_user
    @export_set.create_archive # saves
    flash[:notice] = "Export Set created."
    redirect_to :action => :show, :id => @export_set
  end

  def edit
    # XXX authz
    @export_set = ExportSet.find(params[:id])
    # @response, @document_list = get_solr_response_for_field_values(SolrDocument.unique_key, bookmark_ids)
  end

  def update
    # XXX authz
    @export_set = ExportSet.find(params[:id])
    @export_set.update_attributes(params[:export_set])
    flash[:notice] = "Export Set updated."
    redirect_to :action => :show, :id => @export_set
  end
  
  def destroy
    # XXX authz
    @export_set = ExportSet.find(params[:id])
    @export_set.destroy
    flash[:notice] = "Export Set destroyed."
    redirect_to :action => 'index'
  end

  def archive
    # XXX authz
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
    else
      # XXX 404
    end
    redirect_to :action => :show, :id => @export_set
  end
  
end
