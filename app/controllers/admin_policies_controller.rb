class AdminPoliciesController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::PolicyBehavior

  self.tabs = [:tab_default_permissions,
               :tab_descriptive_metadata,
               :tab_permissions,
               :tab_events]

end
