class ComponentsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior
  include DulHydra::Controller::HasParentBehavior
  include DulHydra::Controller::HasStructuralMetadataBehavior

  def stream
    if current_object.streamable?

      send_file current_object.streamable_media_path,
                type: current_object.streamable_media_type,
                stream: true,
                filename: current_object.id + Ddr::Models.preferred_media_types.key(current_object.streamable_media_type),
                disposition: 'inline'
    else
      render nothing: true, status: 404
    end
  end

end
