class ItemsController < ApplicationController

  load_and_authorize_resource
  
  def index
    @items = Item.all
  end

  def new
    @item = Item.new
  end
  
  def create
    publicReadAdminPolicyPid = "duke-apo:publicread"
    restrictedReadAdminPolicyPid = "duke-apo:restrictedread"
    publicReadAdminPolicy = AdminPolicy.find(publicReadAdminPolicyPid)
    restrictedReadAdminPolicy = AdminPolicy.find(restrictedReadAdminPolicyPid)
    if (params[:item][:pid] == "") || (params[:item][:pid] == "__DO_NOT_USE__")
      params[:item].delete(:pid)
    end
    @item = Item.create(params[:item])
    case params[:policy]
      when "public" then @item.admin_policy = publicReadAdminPolicy
      when "restricted" then @item.admin_policy = restrictedReadAdminPolicy
    end
    @item.save
    redirect_to item_path(@item), :notice=>"Added Item"
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
