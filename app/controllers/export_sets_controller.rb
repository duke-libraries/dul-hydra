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
    flash[:notice] = I18n.t('dul_hydra.export_sets.alerts.created')
    redirect_to action: :show, id: @export_set
  rescue ActiveRecord::InvalidRecord
    render :new
  end

  def edit
  end

  def update
    @export_set.delete_archive unless @export_set.csv_col_sep == params[:export_set][:csv_col_sep]
    @export_set.update!(export_set_params)
    flash[:notice] = I18n.t('dul_hydra.export_sets.alerts.updated')
    redirect_to action: :show, id: @export_set
  rescue ActiveRecord::InvalidRecord
    render :edit
  end

  def destroy
    @export_set.destroy
    flash[:notice] = I18n.t('dul_hydra.export_sets.alerts.destroyed')
    redirect_to action: :index
  end

  def archive
    if request.get?
      if @export_set.has_archive?
        send_file @export_set.archive.path, filename: @export_set.archive_file_name, disposition: 'attachment', type: @export_set.archive_content_type
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
                 when result.is_a?(Exception)
                   500
                 when !result
                   409
                 end
        render nothing: true, status: status
      else
        case
        when result.is_a?(ExportSet)
          flash[:notice] = I18n.t('dul_hydra.export_sets.alerts.archive.created')
        when result.is_a?(Exception)
          flash[:error] = I18n.t('dul_hydra.export_sets.alerts.archive.creation_exception')
        when !result
          flash[:alert] = I18n.t('dul_hydra.export_sets.alerts.archive.not_created')
        end
        redirect_to action: :show, id: @export_set
      end

    elsif request.delete?
      if @export_set.delete_archive
        flash[:notice] = I18n.t('dul_hydra.export_sets.alerts.archive.deleted')
      else
        flash[:alert] = I18n.t('dul_hydra.export_sets.alerts.archive.deletion_failed')
      end
      redirect_to action: :show, id: @export_set
    end
  end

  protected

  def create_archive
    result = @export_set.create_archive
    result ? true : false
  end

  def new_export_set
    @export_set = ExportSet.new(export_set_params)
  end

  private

  def export_set_params
    params.require(:export_set).permit(:title, :export_type, :csv_col_sep, :pids => [])
  end

end
