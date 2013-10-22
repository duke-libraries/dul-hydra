class ApplicationController < ActionController::Base

  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior
  include Hydra::PolicyAwareAccessControlsEnforcement
  include DulHydra::Controller::ControllerBehavior

end
