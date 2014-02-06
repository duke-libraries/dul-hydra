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
    @attachment.attached_to = current_object
    file = params[:content]
    if file
      @attachment.content.content = file
      # XXX Can remove the line below after upgrading to Rubydora 1.7.1+
      @attachment.content.mimeType = file.content_type
      @attachment.source = file.original_filename
    end
    @attachment.set_initial_permissions(current_user)
    if @attachment.save
      PreservationEvent.creation!(@attachment, current_user)
      flash[:success] = "New attachment added."
      redirect_to controller: 'objects', action: 'show', id: current_object, tab: 'attachments'
    else
      logger.error e
      render :new
    end
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
