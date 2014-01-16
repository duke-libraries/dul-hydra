class ExportSetsController < ApplicationController
  
  before_filter :new_export_set, :only => [:create]
  load_and_authorize_resource

  def index
  end
  
  def show
  end
  
  def new
    @export_set.export_type = params[:export_type]
    @export_set.user = current_user # set so we can filter objects based on user's ability
    unless @export_set.valid_type?
      flash[:alert] = if @export_set.export_type 
                        I18n.t('dul_hydra.export_sets.alerts.export_type.invalid') % @export_set.export_type
                      else
                        I18n.t('dul_hydra.export_sets.alerts.export_type.missing')
                      end
      redirect_to :back
    end
  end
  
  def create
    @export_set.update!(user: current_user)
    flash[:notice] = "New export set created."
    redirect_to action: :show, id: @export_set
  rescue ActiveRecord::InvalidRecord
    render :new
  end

  def edit
  end

  def update
    @export_set.update!(export_set_params)
    flash[:notice] = "Export set updated."
    redirect_to action: :show, id: @export_set
  rescue ActiveRecord::InvalidRecord
    render :edit
  end
  
  def destroy
    @export_set.destroy
    flash[:notice] = "Export set destroyed."
    redirect_to action: :index
  end

  def archive
    if request.get?
      if @export_set.has_archive?
        redirect_to @export_set.archive.url
      else
        render status: 404
      end

    elsif request.patch?
      begin
        result = create_archive
      rescue Exception => e
        logger.error e
        result = e
      end
      if request.xhr?     
        status = case
                 when result.is_a?(ExportSet)
                   204
                 when result.is_a?(Delayed::Job)
                   202
                 when result.is_a?(Exception)
                   500
                 when !result
                   409
                 end
        render nothing: true, status: status
      else
        case
        when result.is_a?(ExportSet)
          flash[:notice] = "Archive created."
        when result.is_a?(Delayed::Job)
          flash[:notice] = "The archive is being generated ..."
        when result.is_a?(Exception)
          flash[:error] = "Archive creation failed due to a server error."
        when !result
          flash[:alert] = "Archive already exists or could not be created."
        end
        redirect_to action: :show, id: @export_set
      end

    elsif request.delete?
      if @export_set.delete_archive
        flash[:notice] = "Archive deleted."
      else
        flash[:alert] = "Archive deletion failed."
      end
      redirect_to action: :show, id: @export_set
    end
  end

  protected

  def create_archive
    result = @export_set.create_archive
    result ? (result.is_a?(Delayed::Job) ? result.id : true) : false
  end

  def new_export_set
    @export_set = ExportSet.new(export_set_params)
  end
  
  private
  
  def export_set_params
    params.require(:export_set).permit(:title, :export_type, :pids => [])
  end

end
