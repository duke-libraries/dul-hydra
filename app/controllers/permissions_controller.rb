class PermissionsController < ApplicationController

  include DulHydra::Controller::ObjectsControllerBehavior

  layout 'objects'

  before_filter :authorize_action!

  def edit
    render(params[:default_permissions] ? 'edit_default_permissions' : 'edit')
  end

  def update
    object = ActiveFedora::Base.find(params[:id], cast: true)
    new_permissions = {"group" => {}, "person" => {}}
    all_permissions.each do |access|
      params[:permissions].fetch(access, []).each do |grantee|
        type, name = grantee.split(":", 2)
        type = "person" if type == "user"
        new_permissions[type][name] = access
      end
    end
    if params[:default_permissions]
      object.defaultRights.clear_permissions!
      object.defaultRights.permissions = new_permissions
      object.default_license = params[:license]
      notice = "Default permissions updated."
      redirect_after_update = default_permissions_path(object)
    else
      object.rightsMetadata.clear_permissions!
      object.rightsMetadata.permissions = new_permissions
      object.license = params[:license]
      notice = "Permissions updated."
      redirect_after_update = permissions_path(object)
    end
    object.save
    flash[:notice] = notice
    redirect_to redirect_after_update
  end

  protected

  def authorize_action!
    authorize! params[:action].to_sym, params[:id]
  end

end
