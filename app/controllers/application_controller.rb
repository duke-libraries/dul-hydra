class ApplicationController < ActionController::Base

  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller  

  # Adds Hydra behaviors into the application controller 
  include Hydra::Controller::ControllerBehavior
  
  # specify "application" or "blacklight"
  def layout_name
    #'application'
    'blacklight'
  end

  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  protect_from_forgery
end
