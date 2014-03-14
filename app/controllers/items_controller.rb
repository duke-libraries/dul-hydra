class ItemsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior
  include DulHydra::RepositoryController

  before_action :authorize_add_item

  layout 'objects'

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(params.require(:item).permit(:title, :description))
    @item.collection = current_object
    @item.set_initial_permissions current_user
    @item.copy_admin_policy_or_permissions_from current_object
    if @item.save
      flash[:success] = "New item added."
      redirect_to controller: 'objects', action: 'show', id: current_object, tab: 'items'
    else
      render :new
    end
  end

  protected

  def authorize_add_item
    authorize! :create, Item
    authorize! :add_children, current_object
  end

  def current_object
    @object ||= Collection.find(params[:id])
  end

end
