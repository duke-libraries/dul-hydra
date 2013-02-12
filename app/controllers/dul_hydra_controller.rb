class DulHydraController < ApplicationController

  include Hydra::Controller::ControllerBehavior
  include DulHydra::Controllers::ControllerBehavior
  include DulHydra::Controllers::DatastreamControllerBehavior

  load_and_authorize_resource

  # set @object on new, show, edit
  before_filter :only => [:new, :show, :edit] do |controller|
    @object = controller.instance_variable_get("@#{controller.class.to_s.sub("Controller", "").singularize.downcase}")
  end

  # set @objects on index
  before_filter :only => :index do |controller|
    @objects = controller.instance_variable_get("@#{controller.controller_path.split('/').last}")
  end

end
