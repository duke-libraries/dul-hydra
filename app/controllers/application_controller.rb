class ApplicationController < ActionController::Base

  include Blacklight::Controller
  include Hydra::Controller::ControllerBehavior
  include Hydra::PolicyAwareAccessControlsEnforcement
  include DulHydra::Controller::ControllerBehavior

  # Patches Hydra::AccessControlsEnforcement#escape_filter to support escaping colons
  # cf. https://github.com/projecthydra/hydra-head/pull/115
  def escape_filter(key, value)
    [key, value.gsub(/[ :\/]/, ' ' => '\ ', '/' => '\/', ':' => '\:')].join(':')
  end

end
