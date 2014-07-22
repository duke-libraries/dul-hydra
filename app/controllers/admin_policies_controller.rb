class AdminPoliciesController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::PolicyBehavior

  self.tabs.unshift :tab_default_permissions

  protected

  def after_create_redirect
    {action: :show, id: current_object, tab: "default_permissions"}
  end

end
