class AdminPoliciesController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::PolicyBehavior

  self.tabs.delete :tab_preservation_events

end
