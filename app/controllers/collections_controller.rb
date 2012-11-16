class CollectionsController < ApplicationController

  load_and_authorize_resource
  
  def index
    @collections = Collection.all
  end
  
  def new
    @collection = Collection.new
  end
  
  def create
    publicRead = [{:type=>"group", :access=>"read", :name=>"public"}]
    restrictedRead = [{:type=>"group", :access=>"read", :name=>"repositoryReader"}]
    if (params[:collection][:pid] == "") || (params[:collection][:pid] == "__DO_NOT_USE__")
      params[:collection].delete(:pid)
    end
    @collection = Collection.create(params[:collection])
    case params[:access]
      when "public" then @collection.permissions = publicRead
      when "restricted" then @collection.permissions = restrictedRead
    end
    @collection.save
    redirect_to collection_path(@collection), :notice=>"Added Collection"
  end
  
  def show
    @collection = Collection.find(params[:id])
  end
end
