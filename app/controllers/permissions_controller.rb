class PermissionsController < ApplicationController

  include DulHydra::Controller::ObjectsControllerBehavior

  layout 'objects'

  before_filter :authorize_action!

  def edit
  end

  def update
    object = ActiveFedora::Base.find(params[:id], cast: true)
    permissions = params.fetch(:permissions, {})
    [:discover_users, :read_users, :edit_users, :discover_groups, :read_groups, :edit_groups].each do |method|
      object.send("#{method}=", permissions.fetch(method, []))
    end
    object.save
    flash[:notice] = "Permissions updated."
    redirect_to permissions_path(object)
  end

  protected

  def authorize_action!
    authorize! params[:action].to_sym, params[:id]
  end

end
