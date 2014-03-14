class AdminPoliciesController < ApplicationController

  include DulHydra::RepositoryController

  before_action { |controller| authorize! :create, AdminPolicy }

  def new
    @admin_policy = AdminPolicy.new
  end

  def create
    @admin_policy = AdminPolicy.new(params.require(:admin_policy).permit(:title, :description))
    @admin_policy.set_initial_permissions(current_user)
    if @admin_policy.save
      # @admin_policy.log_event(action: "create", user: current_user)
      flash[:success] = "New AdminPolicy created."
      redirect_to controller: 'objects', action: 'show', id: @admin_policy
    else
      render :new
    end
  end

end
