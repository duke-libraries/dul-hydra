class ComponentsController < ApplicationController

  include Hydra::Controller::UploadBehavior

  def index
    @components = Component.all
  end

  def new
    @component = Component.new
  end

  def create
    component = Component.create
    file = params[:component][:content]
    add_posted_blob_to_asset(component, file)
    redirect_to component_path(component)
  end

  def show
    @component = Component.find(params[:id])
  end

  def update
    component = Component.find(params[:component][:pid])
    item_pid = params[:component][:item]
    if item_pid
      item = Item.find(item_pid)
      component.item = item
      component.save
    end
    redirect_to component_path(component)
  end

end
