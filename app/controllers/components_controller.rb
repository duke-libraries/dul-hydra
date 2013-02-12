class ComponentsController < DulHydraController

  # load_and_authorize_resource

  def index
    @title = "Components"
    @components = Component.all
  end

  def new
    @title = "New Component"
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
    @title = "Component #{@component.pid}"
  end

  def edit
    @title = "Edit Component #{@component.pid}"
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

  # private

  # def set_object
  #   @object = @component
  # end

end
