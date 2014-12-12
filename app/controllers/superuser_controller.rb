class SuperuserController < ApplicationController

  def toggle
    if acting_as_superuser?
      sign_out(:superuser)
      session[:manage_menu].delete(Queue)
      flash[:success] = "You are no longer acting as Superuser."
    else 
      authorize_to_act_as_superuser!
      sign_in(:superuser, current_user)
      session[:manage_menu] << Queue
      flash[:alert] = "<strong>Caution!</strong> You are now acting as Superuser.".html_safe
    end
    redirect_to root_path
  end

  protected 

  def authorize_to_act_as_superuser!
    unless current_user.authorized_to_act_as_superuser?
      render nothing: true, status: 403
    end
  end

end
