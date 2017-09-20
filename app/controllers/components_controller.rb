class ComponentsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasContentBehavior
  include DulHydra::Controller::HasParentBehavior
  include DulHydra::Controller::HasStructuralMetadataBehavior

  def intermediate
    if current_object.has_intermediate_file?

      send_file current_object.intermediate_path,
                type: current_object.intermediate_type,
                filename: [current_object.id, current_object.intermediate_extension].join(".")
    else
      render nothing: true, status: 404
    end
  end


  def stream
    if current_object.streamable?

      send_file current_object.streamable_media_path,
                type: current_object.streamable_media_type,
                stream: true,
                filename: [current_object.id, current_object.streamable_media_extension].join("."),
                disposition: 'inline'
    else
      render nothing: true, status: 404
    end
  end

  def captions
    if current_object.captioned?

      send_file current_object.caption_path,
                type: current_object.caption_type,
                filename: [current_object.id, current_object.caption_extension].join(".")
    else
      render nothing: true, status: 404
    end
  end


end
