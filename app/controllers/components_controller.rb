class ComponentsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior
  include DulHydra::RepositoryController
  include DulHydra::UploadBehavior

  before_action :authorize_add_component

  layout 'objects'

  def new
    @component = Component.new
  end

  def create
    @component = Component.new(params.require(:component).permit(:title, :description))
    upload_content_to @component
    @component.item = current_object
    @component.set_initial_permissions current_user
    @component.copy_admin_policy_or_permissions_from current_object
    if @component.save
      flash[:success] = "New component added."
      redirect_to controller: 'objects', action: 'show', id: current_object, tab: 'components'
    else
      render :new
    end
  end

  protected

  def authorize_add_component
    authorize! :create, Component
    authorize! :add_children, current_object
  end

  def current_object
    @object ||= Item.find(params[:id])
  end

end
