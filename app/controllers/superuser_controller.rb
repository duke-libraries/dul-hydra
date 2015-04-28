class SuperuserController < ApplicationController

  rescue_from ActionController::RedirectBackError do |exception|
    redirect_to root_path
  end

  def toggle
    if acting_as_superuser?
      sign_out(:superuser)
      session[:manage_menu].delete(Queue) if session.key?(:manage_menu)
      flash[:success] = "You are no longer acting as Superuser."
    else
      authorize_to_act_as_superuser!
      sign_in(:superuser, current_user)
      session[:manage_menu] ||= []
      session[:manage_menu] << Queue
      flash[:alert] = "<strong>Caution!</strong> You are now acting as Superuser.".html_safe
    end
    session.delete(:create_menu_models)
    redirect_to :back
  end

  protected

  def authorize_to_act_as_superuser!
    unless current_user.authorized_to_act_as_superuser?
      raise CanCan::AccessDenied
    end
  end

end
