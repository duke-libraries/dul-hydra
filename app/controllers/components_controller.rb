class ComponentsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior
  include DulHydra::RepositoryController

  before_action :authorize_add_component

  rescue_from DulHydra::ChecksumInvalid do |e|
    flash.now[:error] = "<strong>Component creation failed:</strong> #{e.message}".html_safe
    render :new    
  end

  layout 'objects'

  def new
    @component = Component.new
  end

  def create
    @component = Component.new(params.require(:component).permit(:title, :description))
    @component.upload params.require(:content), checksum: params[:checksum]
    @component.item = current_object
    @component.set_initial_permissions current_user
    @component.copy_admin_policy_or_permissions_from current_object
    if @component.save
      flash[:success] = "New component added."
      redirect_to controller: 'objects', action: 'show', id: @component
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
