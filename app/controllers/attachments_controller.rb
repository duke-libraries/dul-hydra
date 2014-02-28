class AttachmentsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior

  before_filter :enforce_show_permissions
  before_filter :authorize_add_attachment

  layout 'objects'

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params.require(:attachment).permit(:title, :description))
    file = params[:content]
    @attachment.content.content = file
    @attachment.content.mimeType = file.content_type
    @attachment.source = file.original_filename
    @attachment.attached_to = current_object
    @attachment.set_initial_permissions(current_user)
    if current_object.has_admin_policy?
      @attachment.admin_policy_id = current_object.admin_policy_id
    else
      @attachment.copy_permissions_from(current_object)
    end
    if @attachment.save
      @attachment.log_event(action: "create", user: current_user)
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
