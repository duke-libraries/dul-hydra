class CollectionsController < ApplicationController

  def index
    @collections = Collection.all
  end
  
  def new
    @collection = Collection.new
  end
  
  def create
    @collection = Collection.create(params[:collection])
    redirect_to collections_path, :notice=>"Added Collection"
  end
end
