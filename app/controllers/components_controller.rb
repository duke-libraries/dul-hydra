class ComponentsController < DulHydraController

  load_and_authorize_resource

  def index
    @components = Component.all
  end

  def new
    # redundant b/c load_and_authorize_resource
    # @component = Component.new
  end

  def create
    if (params[:policypid] && params[:policypid] != "")
      @component.admin_policy = AdminPolicy.find(params[:policypid])
    end
    if params[:contentfile]
      @component.content.content_file = params[:contentfile]
    end
    @component.save
    flash[:notice] = "Component created."
    redirect_to component_path(@component)
  end

  def show
    # redundant b/c load_and_authorize_resource
    # @component = Component.find(params[:id])
  end

  def edit
    # raise NotImplementedError
  end

  def update
    @component.update_attributes(params[:component])
    item_pid = params[:component][:container]
    if item_pid
      @component.container = Item.find(item_pid)
    end
    if params[:contentfile]
      @component.content.content_file = params[:contentfile]
    end
    @component.save
    flash[:notice] = "Component updated."
    redirect_to component_path(@component)
  end

  def destroy
    raise NotImplementedError
  end

end
