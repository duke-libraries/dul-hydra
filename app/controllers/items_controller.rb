class ItemsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasParentBehavior
  include DulHydra::Controller::HasChildrenBehavior

  self.tabs.unshift :tab_components

  protected

  def tab_components
    tab_children("components")
  end

end
