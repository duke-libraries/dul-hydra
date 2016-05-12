class ComponentsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior
  include DulHydra::Controller::HasParentBehavior

  def admin_metadata_fields
    super + [ :multires_image_file_path ]
  end

end
