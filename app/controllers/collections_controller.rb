class CollectionsController < ApplicationController

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
    redirect_to collections_path, :notice=>"Added Collection"
  end
end
