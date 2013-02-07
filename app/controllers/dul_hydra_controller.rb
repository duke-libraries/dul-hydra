class DulHydraController < ApplicationController

  include Hydra::Controller::ControllerBehavior
  include DulHydra::Controllers::ControllerBehavior
  include DulHydra::Controllers::DatastreamControllerBehavior
  # load_and_authorize_resource 

end
