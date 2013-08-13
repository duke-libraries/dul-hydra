class BatchesController < ApplicationController
  
  load_and_authorize_resource :class => DulHydra::Batch::Models::Batch

  def index
  end
  
  def show
  end
  
  def procezz
    Delayed::Job.enqueue DulHydra::Batch::Jobs::BatchProcessorJob.new(@batch.id)
    flash[:notice] = I18n.t('batch.web.batch_queued', :id => @batch.id)
    redirect_to batches_url
  end
end