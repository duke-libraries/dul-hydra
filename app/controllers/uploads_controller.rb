class UploadsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior
  include DulHydra::EventLogBehavior
  after_action :log_upload, only: :update

  before_action do |controller|
    authorize! :upload, current_object
  end

  layout 'objects'

  def show
    content_warning
  end

  def update
    if current_object.upload!(params.require(:content))
      flash[:notice] = "Content successfully uploaded."
      redirect_to controller: 'objects', action: 'show', id: current_object
    else
      content_warning
      render :show
    end
  end

  protected

  def log_upload
    log_action object: current_object, action: EventLog::Actions::UPLOAD
  end

  def content_warning
    if current_object.has_content?
      flash.now[:error] = "<strong>Warning!</strong> #{I18n.t('dul_hydra.upload.alerts.has_content')}".html_safe
    end
  end

end
