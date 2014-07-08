class AdminPoliciesController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::PolicyBehavior

  self.tabs.unshift :tab_default_permissions

end
