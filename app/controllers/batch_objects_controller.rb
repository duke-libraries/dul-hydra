class BatchObjectsController < ApplicationController
  
  load_and_authorize_resource :class => DulHydra::Batch::Models::BatchObject
  
  def index
  end
  
  def show
  end
  
end