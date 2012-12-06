class CollectionsController < ApplicationController

  load_and_authorize_resource
  
  def index
    @collections = Collection.all
  end
  
  def new
    @collection = Collection.new
    # @default_apo = AdminPolicy.default_apo(create: true)
    @apos = AdminPolicy.all
  end
  
  def create
    if (params[:collection][:pid] == "") || (params[:collection][:pid] == "__DO_NOT_USE__")
      params[:collection].delete(:pid)
    end
    @collection = Collection.new(params[:collection])
    if (params[:policypid] && params[:policypid] != "")
      @collection.admin_policy = AdminPolicy.find(params[:policypid])
    end
    @collection.save
    redirect_to collection_path(@collection), :notice=>"Added Collection"
  end
  
  def show
    # redundant b/c load_and_authorize_resource
    # @collection = Collection.find(params[:id])
  end
end
