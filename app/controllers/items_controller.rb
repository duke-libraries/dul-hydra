class ItemsController < ApplicationController

  include DulHydra::Controller::RepositoryBehavior
  include DulHydra::Controller::HasParentBehavior
  include DulHydra::Controller::HasChildrenBehavior

  def components
    get_children
  end

  protected

  def create_params
    params.permit(:descMetadata).permit(title: [])
  end

  def after_create_success
    return unless params[:content].present?
    child_params = params[:content]
    if child_params[:file].present?
      # create the component
      child = Component.new(parent_id: current_object.pid)
      # set permissions on the component
      child.set_initial_permissions current_user
      # upload the file
      child.upload child_params[:file]
      if child.save
        notify_event :creation, pid: child.pid
        # verify checksum if provided
        if child_params[:checksum].present?
          begin
            checksum, checksum_type = child_params.values_at :checksum, :checksum_type
            child.validate_checksum! checksum, checksum_type
          rescue DulHydra::ChecksumInvalid => e
            flash[:error] = e.message
          else
            flash[:info] = "The checksum provided [#{checksum_type}: #{checksum}] was validated against the repository content."
          end
        end
      else # component creation failed
        error_messages = child.errors.full_messages.join("<br />")
        flash[:error] = "The component was not created: #{error_messages}".html_safe
      end
    else
      # Checksum provided for component without file
      flash[:error] = "The component was not created: File missing." if child_params[:checksum].present?
    end
  end

end
