class ItemsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasParentBehavior
  include DulHydra::Controller::HasChildrenBehavior

  self.tabs.unshift :tab_components

end
