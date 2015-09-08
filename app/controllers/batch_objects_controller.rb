class BatchObjectsController < ApplicationController

  load_and_authorize_resource :class => Ddr::Batch::BatchObject

  def index
  end

  def show
  end

end
