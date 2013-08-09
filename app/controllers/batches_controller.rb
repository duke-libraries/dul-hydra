class BatchesController < ApplicationController
  
  load_and_authorize_resource :class => DulHydra::Batch::Models::Batch

  def index
  end
  
  def show
  end
  
end