class AttachmentsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior
  include DulHydra::EventLogBehavior
  log_actions :create

  before_action :authorize_add_attachment

  rescue_from DulHydra::ChecksumInvalid do |e|
    flash.now[:error] = "<strong>Attachment creation failed:</strong> #{e.message}".html_safe
    render :new
  end

  layout 'objects'

  def new
    @attachment = Attachment.new
  end

  def create
    @attachment = Attachment.new(params.require(:attachment).permit(:title, :description))
    @attachment.upload params.require(:content), checksum: params[:checksum]
    @attachment.attached_to = current_object
    @attachment.set_initial_permissions current_user
    @attachment.copy_admin_policy_or_permissions_from current_object
    if @attachment.save
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
