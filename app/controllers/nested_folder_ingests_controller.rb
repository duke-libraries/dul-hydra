class NestedFolderIngestsController < ApplicationController

  load_resource
  before_action :authorize_create, only: [:create]

  def create
    authorize! :create, @nested_folder_ingest
    @nested_folder_ingest.user = current_user
    if @nested_folder_ingest.valid?
      Resque.enqueue(NestedFolderIngestJob,
                     'admin_set' => @nested_folder_ingest.admin_set,
                     'basepath' => @nested_folder_ingest.basepath,
                     'batch_user' => @nested_folder_ingest.user.user_key,
                     'checksum_file' => @nested_folder_ingest.checksum_file,
                     'collection_id' => @nested_folder_ingest.collection_id,
                     'collection_title' => @nested_folder_ingest.collection_title,
                     'config_file' => @nested_folder_ingest.config_file,
                     'metadata_file' => @nested_folder_ingest.metadata_file,
                     'subpath' => @nested_folder_ingest.subpath)
      render "queued"
    else
      render "new"
    end
  end

  private

  def create_params
    params.require(:nested_folder_ingest).permit(:admin_set, :basepath, :checksum_file, :collection_id,
                                                 :collection_title, :config_file, :metadata_file, :subpath)
  end

  def authorize_create
    if (collection_id = @nested_folder_ingest.collection_id).present?
      if can?(:add_children, collection_id)
        current_ability.can :create, NestedFolderIngest, collection_id: collection_id
      else
        current_ability.cannot :create, NestedFolderIngest, collection_id: collection_id
      end
    end
  end

end
