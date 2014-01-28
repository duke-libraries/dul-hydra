class AttachmentsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior

  before_filter :enforce_show_permissions
  before_filter :authorize_add_attachment

  layout 'objects'

  def new
  end

  def create
    @attachment = Attachment.new(attachment_params)
    file = params[:content]
    @attachment.content.content = file
    @attachment.content.mimeType = file.content_type
    @attachment.source = file.original_filename
    @attachment.save!
    flash[:success] = "New attachment added."
    redirect_to controller: 'objects', action: 'show', id: current_object, tab: 'attachments'
  rescue
    render :new
  end

  protected

  def authorize_add_attachment
    authorize! :add_attachment, current_object
  end

  private

  def attachment_params
    params.require(:attachment).permit(:title, :description)
  end

end
