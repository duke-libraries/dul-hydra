class AttachmentsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior
  include DulHydra::UploadBehavior

  before_filter :enforce_show_permissions
  before_filter :authorize_add_attachment

  layout 'objects'

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params.require(:attachment).permit(:title, :description))
    upload @attachment
    @attachment.attached_to = current_object
    @attachment.set_initial_permissions current_user
    @attachment.copy_admin_policy_or_permissions_from current_object
    if @attachment.save
      @attachment.log_event action: "create", user: current_user
      flash[:success] = "New attachment added."
      redirect_to controller: 'objects', action: 'show', id: current_object, tab: 'attachments'
    else
      render :new
    end
  end

  protected

  def authorize_add_attachment
    authorize! :create, Attachment
    authorize! :add_attachment, current_object
  end

end
