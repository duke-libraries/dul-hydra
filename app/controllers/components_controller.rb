class ComponentsController < ApplicationController

  include Hydra::Controller::UploadBehavior

  def index
    @components = Component.all
  end

  def new
    @component = Component.new
  end

  # def create
  #   component = Component.create
  #   file = params[:component][:content]
  #   add_posted_blob_to_asset(component, file)
  #   redirect_to component_path(component)
  # end

  def show
    @component = Component.find(params[:id])
  end

end
