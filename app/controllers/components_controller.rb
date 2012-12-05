class ComponentsController < ApplicationController

  load_and_authorize_resource

  def index
    @components = Component.all
  end

  def new
    @component = Component.new
  end

  def create
    @component = Component.new
    if (params[:policypid] && params[:policypid] != "")
      @component.admin_policy = AdminPolicy.find(params[:policypid])
    end
    if params[:contentfile]
      @component.content_file = params[:contentfile]
    end
    @component.save
    flash[:notice] = "Component created."
    redirect_to component_path(@component)
  end

  def show
    # redundant b/c load_and_authorize_resource
    # @component = Component.find(params[:id])
  end

  def update
    @component = Component.find(params[:component][:pid])
    item_pid = params[:component][:container]
    if item_pid
      @component.container = Item.find(item_pid)
      @component.save
      flash[:notice] = "Added to Item #{item_pid}."
    end
    if params[:contentfile]
      @component.content_file = params[:contentfile]
      flash[:notice] = "Content added."
    end
    redirect_to component_path(@component)
  end

end
