class BatchObjectsController < ApplicationController

  load_and_authorize_resource :class => Ddr::Batch::BatchObject

  def show
  end

end
