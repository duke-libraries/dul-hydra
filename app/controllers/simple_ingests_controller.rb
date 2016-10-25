class SimpleIngestsController < ApplicationController

  load_resource
  before_action :authorize_create, only: [:create]

  def create
    authorize! :create, @simple_ingest
    @simple_ingest.user = current_user
    if @simple_ingest.valid?
      Resque.enqueue(SimpleIngestJob,
                     'admin_set' => @simple_ingest.admin_set,
                     'batch_user' => @simple_ingest.user.user_key,
                     'collection_id' => @simple_ingest.collection_id,
                     'config_file' => @simple_ingest.config_file,
                     'folder_path' => @simple_ingest.folder_path)
      render "queued"
    else
      render "new"
    end
  end

  private

  def create_params
    params.require(:simple_ingest).permit(:folder_path, :admin_set, :collection_id, :config_file)
  end

  def authorize_create
    if (collection_id = @simple_ingest.collection_id).present?
      if can?(:add_children, collection_id)
        current_ability.can :create, SimpleIngest, collection_id: collection_id
      else
        current_ability.cannot :create, SimpleIngest, collection_id: collection_id
      end
    end
  end

end
