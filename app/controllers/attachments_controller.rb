class AttachmentsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior

  prepend_before_action :authorize_add_attachment!, only: [:new, :create]
  before_action :set_desc_metadata, only: :create
  before_action :copy_admin_policy_or_permissions, only: :create

  helper_method :attached_to

  protected

  def create_params
    {attached_to_id: attached_to_param}
  end

  def attached_to
    @attached_to ||= ActiveFedora::Base.find attached_to_param
  end

  def attached_to_param
    params.require(:attached_to_id)
  end

  def authorize_add_attachment!
    authorize! :add_attachment, attached_to
  end

  def copy_admin_policy_or_permissions
    current_object.copy_admin_policy_or_permissions_from attached_to
  end

end
