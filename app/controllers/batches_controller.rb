class BatchesController < ApplicationController
  
  load_and_authorize_resource :class => DulHydra::Batch::Models::Batch

  include DulHydra::Controller::TabbedViewBehavior
  self.tabs = [:tab_pending_batches, :tab_finished_batches]

  def index
    @pending = []
    @finished = []
    @batches.each do |batch|
      if batch.finished?
        @finished << batch
      else
        @pending << batch
      end
    end
  end
  
  def show
    @batch_objects = @batch.batch_objects.page params[:page]
  end
  
  def destroy
    case @batch.status
    when nil, DulHydra::Batch::Models::Batch::STATUS_READY, DulHydra::Batch::Models::Batch::STATUS_VALIDATED, DulHydra::Batch::Models::Batch::STATUS_INVALID
      @batch.destroy
      flash[:notice] = I18n.t('batch.web.batch_deleted', :id => @batch.id)
    else
      flash[:notice] = I18n.t('batch.web.batch_not_deletable', :id => @batch.id, :status => @batch.status)
    end
    redirect_to action: :index
  end
  
  def procezz
    Resque.enqueue(DulHydra::Batch::Jobs::BatchProcessorJob, @batch.id, current_user.id)
    flash[:notice] = I18n.t('batch.web.batch_queued', :id => @batch.id)
    redirect_to batches_url
  end
  
  def validate
    referrer = request.env['HTTP_REFERER']
    @errors = @batch.validate
    valid = @errors.empty?
    if valid
      @batch.status = DulHydra::Batch::Models::Batch::STATUS_VALIDATED
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

  protected
  
  def tab_pending_batches
    Tab.new("pending_batches")
  end
  
  def tab_finished_batches
    Tab.new("finished_batches")
  end
  
end
