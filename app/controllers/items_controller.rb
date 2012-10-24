class ItemsController < ApplicationController

  def index
    @items = Item.all
  end

  def show
    @item = Item.find(params[:id])
  end

  def update
    item = Item.find(params[:item][:pid])
    if params[:item][:collection]
      # XXX check whether collection pid exists and is a Collection object
      collection = Collection.find(params[:item][:collection])
      item.collection = collection
      item.save
    end
    redirect_to item_path(item)
  end

end
