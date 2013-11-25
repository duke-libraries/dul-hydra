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
  end
  
  def procezz
    Delayed::Job.enqueue DulHydra::Batch::Jobs::BatchProcessorJob.new(@batch.id)
    flash[:notice] = I18n.t('batch.web.batch_queued', :id => @batch.id)
    redirect_to batches_url
  end
  
  def validate
    @errors = @batch.validate
    valid = @errors.empty?
    flash[:notice] = "Batch is #{valid ? '' : 'not '}valid"
    render :show
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