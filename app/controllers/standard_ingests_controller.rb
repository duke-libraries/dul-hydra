class StandardIngestsController < ApplicationController

  load_resource
  before_action :authorize_create, only: [:create]

  def create
    authorize! :create, @standard_ingest
    @standard_ingest.user = current_user
    if @standard_ingest.valid?
      Resque.enqueue(StandardIngestJob,
                     'admin_set' => @standard_ingest.admin_set,
                     'batch_user' => @standard_ingest.user.user_key,
                     'collection_id' => @standard_ingest.collection_id,
                     'config_file' => @standard_ingest.config_file,
                     'folder_path' => @standard_ingest.folder_path)
      render "queued"
    else
      render "new"
    end
  end

  private

  def create_params
    params.require(:standard_ingest).permit(:folder_path, :admin_set, :collection_id, :config_file)
  end

  def authorize_create
    if (collection_id = @standard_ingest.collection_id).present?
      if can?(:add_children, collection_id)
        current_ability.can :create, StandardIngest, collection_id: collection_id
      else
        current_ability.cannot :create, StandardIngest, collection_id: collection_id
      end
    end
  end

end
