class AttachmentsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior

  before_filter :enforce_show_permissions
  before_filter :authorize_add_attachment

  layout 'objects'

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(attachment_params)
    if file = params[:content]
      @attachment.content.content = file
      @attachment.source = file.original_filename
    end
    @attachment.attached_to = current_object
    @attachment.save!
    flash[:success] = "New attachment added."
    redirect_to controller: 'objects', action: 'show', id: current_object, tab: 'attachments'
  rescue ActiveFedora::RecordInvalid => e
    logger.error e
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
