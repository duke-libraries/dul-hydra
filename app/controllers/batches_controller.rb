class BatchesController < ApplicationController

  load_and_authorize_resource :class => Ddr::Batch::Batch

  def index
    @batches = @batches.includes(:batch_objects, :user).order('id DESC').page(params[:page]).per(DulHydra.batches_per_page)
    if params[:filter] == "current_user"
      @batches = @batches.where(user: current_user)
      render 'my_batches'
    else
      render 'index'
    end
  end

  def show
    @batch_objects = @batch.batch_objects.page params[:page]
  end

  def destroy
    if @batch.deletable?
      Resque.enqueue(Ddr::Batch::BatchDeletionJob, @batch.id)
      flash[:notice] = I18n.t('batch.web.batch_deleting', :id => @batch.id)
    else
      flash[:notice] = I18n.t('batch.web.batch_not_deletable', :id => @batch.id, :status => @batch.status)
    end
    redirect_to action: :index
  end

  def procezz
    Resque.enqueue(Ddr::Batch::BatchProcessorJob, @batch.id, current_user.id)
    flash[:notice] = I18n.t('batch.web.batch_queued', :id => @batch.id)
    redirect_to batch_url
  end

  def validate
    referrer = request.env['HTTP_REFERER']
    @errors = @batch.validate
    valid = @errors.empty?
    if valid
      @batch.status = Ddr::Batch::Batch::STATUS_VALIDATED
      @batch.save
    end
    flash[:notice] = "Batch is #{valid ? '' : 'not '}valid"
    if valid && referrer == url_for(action: 'index', only_path: false)
      redirect_to batches_url
    else
      # render :show
      redirect_to batch_url(@batch.id)
    end
  end

end
