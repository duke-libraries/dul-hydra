class DulHydraController < ApplicationController

  include Hydra::Controller::ControllerBehavior
  include DulHydra::Controller::ControllerBehavior
  load_and_authorize_resource

end
