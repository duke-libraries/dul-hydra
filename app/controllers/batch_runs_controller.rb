class BatchRunsController < ApplicationController
  
  load_and_authorize_resource :class => DulHydra::Batch::Models::Batch_Run

  def index
  end
  
  def show
  end
  
end