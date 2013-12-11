class MetadataFilesController < ApplicationController
  
	load_resource
	
	def new
	end
	
	def create
	  @metadata_file = MetadataFile.new(params[:metadata_file])
	  @metadata_file.user = current_user
	  @metadata_file.options = MetadataFile.default_options
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
	
end	