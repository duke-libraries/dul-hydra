class CollectionsController < ApplicationController

  load_and_authorize_resource
  
  def index
    @collections = Collection.all
  end
  
  def new
    @collection = Collection.new
  end
  
  def create
    if (params[:collection][:pid] == "") || (params[:collection][:pid] == "__DO_NOT_USE__")
      params[:collection].delete(:pid)
    end
    @collection = Collection.create(params[:collection])
    if (params[:policypid] && params[:policypid] != "")
      apo = AdminPolicy.find(params[:policypid])
      @collection.admin_policy = apo
      @collection.save
    end
    redirect_to collection_path(@collection), :notice=>"Added Collection"
  end
  
  def show
    # redundant b/c load_and_authorize_resource
    # @collection = Collection.find(params[:id])
  end
end
