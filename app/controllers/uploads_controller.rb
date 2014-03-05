class UploadsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior
  include DulHydra::UploadBehavior

  before_action do |controller|
    authorize! :upload, current_object
  end

  layout 'objects'

  def show
    content_warning
  end

  def update
    upload current_object
    if current_object.save
      log_event
      flash[:notice] = "Content successfully uploaded."
      redirect_to controller: 'objects', action: 'show', id: current_object
    else
      content_warning
      render :show
    end
  end

  protected

  def content_warning
    if current_object.has_content?
      flash.now[:error] = "<strong>Warning!</strong> #{I18n.t('dul_hydra.upload.alerts.has_content')}".html_safe
    end
  end

end
