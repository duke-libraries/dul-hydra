class ComponentsController < ApplicationController

  def index
    @components = Component.all
  end

  def new
    @component = Component.new
  end

  def create
    component = Component.create
    file = params[:component][:content]
    component.add_content(file)
    flash[:notice] = "Component created."
    redirect_to component_path(component)
  end

  def show
    @component = Component.find(params[:id])
  end

  def update
    component = Component.find(params[:component][:pid])
    # add component to item
    item_pid = params[:component][:container]
    if item_pid
      item = Item.find(item_pid)
      component.container = item
      component.save
      flash[:notice] = "Added to Item #{item.pid}."
    end
    # add content to component
    content = params[:component][:content]
    if content
      component.add_content(content)
      flash[:notice] = "Content added."
    end
    redirect_to component_path(component)
  end

end
