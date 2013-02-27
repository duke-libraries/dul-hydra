require 'zip/zip'

class ExportSetsController < ApplicationController
  
  include Blacklight::SolrHelper
  
  def index
    @export_sets = ExportSet.where(:user_id => current_user)
    if @export_sets.empty?
      flash[:notice] = "You have no export sets."
    end
  end
  
  def show
    @export_set = ExportSet.find(params[:id])
  end
  
  def new
    @export_set = ExportSet.new   
    bookmark_ids = current_user.bookmarks.collect { |b| b.document_id.to_s }
    @response, @document_list = get_solr_response_for_field_values(SolrDocument.unique_key, bookmark_ids)
    # hack to filter just Components
    # would be nice to filter DulHydra::Models::HasContent
    @document_list.keep_if { |doc| doc.get(:active_fedora_model_s) == 'Component' }
    if @document_list.empty
      flash[:notice] = "You have no bookmarks for content-bearing objects."
    end
  end
  
  def create
    @export_set = ExportSet.new(params[:export_set])
    @export_set.user = current_user
    Dir.mktmpdir do |tmpdir|
      # create the zip archive
      zip_name = "export_set_#{Time.now.strftime('%Y%m%d%H%M%S')}.zip"
      zip_path = File.join(tmpdir, zip_name)
      Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE) do |zip_file|
        @export_set.pids.each do |pid|
          # get Fedora object
          object = ActiveFedora::Base.find(pid, :cast => true)
          # write content to file
          file_name = object.content.default_file_name
          file_path = File.join(tmpdir, file_name)
          File.open(file_path, 'wb', :encoding => 'ascii-8bit') do |f|
            object.content.write_content(f)
          end
          zip_file.add(file_name, file_path)
        end # document_list
      end # zip_file
      # update_attributes seems to be the way to get paperclip to work 
      # when not using file upload form submission to create the attachment
      @export_set.update_attributes({:archive => File.new(zip_path, "rb")})
    end # tmpdir is removed
    flash[:notice] = "Export Set created."
    # stream the zip file to client
    #send_file @export_set.archive.path, :filename => @export_set.archive_file_name, 
    #      :type => @export_set.archive.content_type || 'application/zip'
    redirect_to :action => :show, :id => @export_set
  end
  
  def destroy
    @export_set = ExportSet.find(params[:id])
    @export_set.destroy
    flash[:notice] = "Export Set destroyed."
    redirect_to :action => 'index'
  end
  
end