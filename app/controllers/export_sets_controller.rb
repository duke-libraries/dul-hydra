class ExportSetsController < ApplicationController
  
  include Blacklight::Catalog

  before_filter :new_export_set, :only => [:create]

  load_and_authorize_resource

  def new_export_set
    @export_set = ExportSet.new(export_set_params)
  end
  
  def index
  end
  
  def show
    @response, @documents = get_solr_response_for_field_values(SolrDocument.unique_key, @export_set.pids)
  end
  
  def new
    @response, @documents = get_solr_response_for_field_values(SolrDocument.unique_key, 
                                                               current_user.bookmarked_document_ids)
    @documents.keep_if { |doc| doc.has_content? and can?(:read, doc) }
  end
  
  def create
    @export_set.user = current_user
    flash[:notice] = @export_set.create_archive ? "New export set created." : "Export set archive creation failed."
    @export_set.save if @export_set.new_record?
    redirect_to :action => :show, :id => @export_set
  end

  def edit
  end

  def update
    @export_set.update(export_set_params)
    flash[:notice] = "Export set updated."
    redirect_to :action => :show, :id => @export_set
  end
  
  def destroy
    @export_set.destroy
    flash[:notice] = "Export set destroyed."
    redirect_to :action => :index
  end

  def archive
    if request.delete?
      unless @export_set.archive_file_name.nil?
        @export_set.archive = nil
        @export_set.save
        flash[:notice] = "Archive deleted."
      end
    elsif request.post?
      flash[:notice] = if @export_set.archive_file_name.nil?
                         @export_set.create_archive ? "Archive created." : "Archive creation failed."
                       else
                         "Archive already exists."
                       end
    end
    redirect_to :action => :show, :id => @export_set
  end
  
  private
  
  def export_set_params
    puts params
    params.require(:export_set).permit(:archive, :title, :pids => [])
  end

end
