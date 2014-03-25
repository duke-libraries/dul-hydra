class AttachmentsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior

  prepend_before_action :authorize_add_attachment!, only: [:new, :create]
  before_action :attach, only: :create
  before_action :copy_admin_policy_or_permissions, only: :create

  helper_method :attach_to

  protected

  def attach
    current_object.attached_to = attach_to
  end

  def attach_to
    @attach_to ||= ActiveFedora::Base.find(params.require(attach_to_param), cast: true)
  end

  def attach_to_param
    :attach_to
  end

  def authorize_add_attachment!
    authorize! :add_attachment, attach_to
  end

  def copy_admin_policy_or_permissions
    current_object.copy_admin_policy_or_permissions_from attach_to
  end

end
