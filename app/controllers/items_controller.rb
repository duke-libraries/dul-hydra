class ItemsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasParentBehavior
  include DulHydra::Controller::HasChildrenBehavior

  def components
    get_children
  end

end
