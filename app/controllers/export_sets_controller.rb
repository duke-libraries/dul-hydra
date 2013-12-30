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
    @export_set.user = current_user
    @export_set.create_archive
    @export_set.save!
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
    if request.delete?
      unless @export_set.archive_file_name.nil?
        @export_set.archive = nil
        @export_set.save!
        flash[:notice] = "Archive deleted."
      end
    elsif request.post?
      if @export_set.archive_file_name.nil?
        if @export_set.create_archive
          flash[:notice] = "Archive created."
        else
          flash[:alert] = "Archive creation failed."
        end
      else
        flash[:alert] = "Archive already exists."
      end
    end
    redirect_to export_set_path(@export_set)
  end

  protected

  def new_export_set
    @export_set = ExportSet.new(export_set_params)
  end
  
  private
  
  def export_set_params
    params.require(:export_set).permit(:title, :export_type, :pids => [])
  end

end
