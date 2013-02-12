class CollectionsController < DulHydraController

  def index
    @collections = Collection.all
  end
  
  def new
    @title = "New Collection"
  end
  
  def show
    @title = "Collection #{@collection.pid}"
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

  def edit
    @title = "Edit Collection #{@collection.pid}"
  end

  def update
    raise NotImplementedError
  end
  
  def destroy
    raise NotImplementedError
  end

end
