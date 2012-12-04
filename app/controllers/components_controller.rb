class ComponentsController < ApplicationController

  load_and_authorize_resource

  def index
    @components = Component.all
  end

  def new
    @component = Component.new
  end

  def create
    @component = Component.create
    if (params[:policypid] && params[:policypid] != "")
      apo = AdminPolicy.find(params[:policypid])
      @component.admin_policy = apo
      @component.save
    end
    file = params[:contentfile]
    @component.add_content(file)
    flash[:notice] = "Component created."
    redirect_to component_path(@component)
  end

  def show
    # redundant b/c load_and_authorize_resource
    # @component = Component.find(params[:id])
  end

  def update
    @component = Component.find(params[:component][:pid])
    # add component to item
    item_pid = params[:component][:container]
    if item_pid
      item = Item.find(item_pid)
      @component.container = item
      @component.save
      flash[:notice] = "Added to Item #{item.pid}."
    end
    # add content to component
    contentfile = params[:contentfile]
    if contentfile
      @component.add_content(contentfile)
      flash[:notice] = "Content added."
    end
    redirect_to component_path(@component)
  end

end
