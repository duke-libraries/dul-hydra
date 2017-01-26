class ComponentsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior
  include DulHydra::Controller::HasParentBehavior
  include DulHydra::Controller::HasStructuralMetadataBehavior

end
