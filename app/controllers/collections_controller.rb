class CollectionsController < ApplicationController

  load_and_authorize_resource
  
  def index
    @collections = Collection.all
  end
  
  def new
    @collection = Collection.new
  end
  
  def create
    publicReadAdminPolicyPid = "duke-apo:publicread"
    restrictedReadAdminPolicyPid = "duke-apo:restrictedread"
    publicReadAdminPolicy = AdminPolicy.find(publicReadAdminPolicyPid)
    restrictedReadAdminPolicy = AdminPolicy.find(restrictedReadAdminPolicyPid)
    if (params[:collection][:pid] == "") || (params[:collection][:pid] == "__DO_NOT_USE__")
      params[:collection].delete(:pid)
    end
    @collection = Collection.create(params[:collection])
    case params[:policy]
      when "public" then @collection.admin_policy = publicReadAdminPolicy
      when "restricted" then @collection.admin_policy = restrictedReadAdminPolicy
    end
    @collection.save
    redirect_to collection_path(@collection), :notice=>"Added Collection"
  end
  
  def show
    @collection = Collection.find(params[:id])
  end
end
