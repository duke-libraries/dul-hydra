class ItemsController < ApplicationController

  load_and_authorize_resource
  
  def index
    @items = Item.all
  end

  def new
    # redundant b/c load_and_authorize_resource
    # @item = Item.new
  end
  
  def create
    if (params[:item][:pid] == "") || (params[:item][:pid] == "__DO_NOT_USE__")
      params[:item].delete(:pid)
    end
    @item = Item.create(params[:item])
    if (params[:policypid] && params[:policypid] != "")
      apo = AdminPolicy.find(params[:policypid])
      @item.admin_policy = apo
      @item.save
    end
    redirect_to item_path(@item), :notice => "Added Item"
  end
  
  def show
    # redundant b/c load_and_authorize_resource
    # @item = Item.find(params[:id])
  end

  def edit
  end

  def update
    # redundant b/c load_and_authorize_resource
    # item = Item.find(params[:id])
    if params[:item][:collection]
      # raises exception on not found
      collection = Collection.find(params[:item][:collection])
      @item.collection = collection
      @item.save
    end
    redirect_to item_path(@item)
  end

  def destroy
    raise NotImplementedError
  end

end
