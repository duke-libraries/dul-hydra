require 'dul_hydra'

class ApplicationController < ActionController::Base

  include Blacklight::Controller
  include Ddr::Auth::RoleBasedAccessControlsEnforcement

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :acting_as_superuser?

  rescue_from CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403", formats: [:html], status: 403, layout: false
  end

  def acting_as_superuser?
    signed_in?(:superuser)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password, :remember_me) }
  end

end
