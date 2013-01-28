class ApplicationController < ActionController::Base

  # Adds a few additional behaviors into the application controller 
  include Blacklight::Controller  

  # Adds Hydra behaviors into the application controller 
  # Moved to CatalogController - https://github.com/duke-libraries/dul-hydra/issues/51
  #include Hydra::Controller::ControllerBehavior
  #include Hydra::PolicyAwareAccessControlsEnforcement
  
  rescue_from CanCan::AccessDenied do |exception|
    render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403, :layout => false
  end

  layout 'blacklight'
  # # specify "application" or "blacklight"
  # def layout_name
  #   #'application'
  #   'blacklight'
  # end

  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  protect_from_forgery
end
