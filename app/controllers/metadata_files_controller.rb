class MetadataFilesController < ApplicationController
  
  before_filter :new_metadata_file, :only => [:create]

	load_and_authorize_resource
	
  def new_metadata_file
    @metadata_file = MetadataFile.new(metadata_file_params)
  end
  
	def new
	end
	
	def create
	  @metadata_file.user = current_user
    if @metadata_file.save
      redirect_to :action => :show, :id => @metadata_file
    else
      render :new
    end
  end
  
  def show
  end
  
  def procezz
    @metadata_file.procezz
    redirect_to :controller => :batches, :action => :index    
  end
	
	private
	
  def metadata_file_params
    params.require(:metadata_file).permit(:collection_pid, :metadata, :profile)
  end

end	