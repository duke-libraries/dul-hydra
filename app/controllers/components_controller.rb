class ComponentsController < ApplicationController

  def index
    @components = Component.all
  end

end
