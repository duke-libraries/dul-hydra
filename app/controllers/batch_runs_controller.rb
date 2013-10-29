class BatchRunsController < ApplicationController
  
  load_and_authorize_resource :class => DulHydra::Batch::Models::BatchRun

  def index
  end
  
  def show
  end
  
end