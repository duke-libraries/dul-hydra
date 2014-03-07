class BatchesController < ApplicationController
  
  load_and_authorize_resource :class => DulHydra::Batch::Models::Batch

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
  
  def procezz
    Delayed::Job.enqueue DulHydra::Batch::Jobs::BatchProcessorJob.new(@batch.id)
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
  
  def tabs
    methods = [:tab_pending_batches, :tab_finished_batches]
    Tabs.new(self, *methods)
  end
  
  def tab_pending_batches
    Tab.new("pending_batches")
  end
  
  def tab_finished_batches
    Tab.new("finished_batches")
  end
  
end