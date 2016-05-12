class SuperuserController < ApplicationController

  before_action :authorize_to_act_as_superuser!, only: :create
  after_action :cleanup_session

  rescue_from ActionController::RedirectBackError do |exception|
    redirect_to root_path
  end

  def create
    sign_in(:superuser, current_user)
    session[:manage_menu] ||= []
    session[:manage_menu] << "Queue"
    flash[:alert] = "Caution! You are now acting as Superuser."
    redirect_to :back
  end

  def destroy
    sign_out(:superuser)
    session[:manage_menu].delete("Queue") if session.key?(:manage_menu)
    flash[:success] = "You are no longer acting as Superuser."
    redirect_to root_path
  end

  protected

  def authorize_to_act_as_superuser!
    unless authorized_to_act_as_superuser?
      raise CanCan::AccessDenied
    end
  end

  def cleanup_session
    session.delete(:create_menu_models)
  end

end
