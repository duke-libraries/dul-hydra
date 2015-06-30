class AttachmentsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior

  before_action :set_desc_metadata, only: :create
  before_action :copy_admin_policy_or_roles_from_attached_to, only: :create

  delegate :attached_to, to: :current_object

  helper_method :attached_to

  protected

  def after_load_before_authorize
    current_object.attached_to_id = params.require(:attached_to_id)
  end

  def copy_admin_policy_or_roles_from_attached_to
    current_object.copy_admin_policy_or_roles_from(attached_to)
  end

end
