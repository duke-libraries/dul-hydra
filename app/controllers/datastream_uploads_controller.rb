class DatastreamUploadsController < ApplicationController

  load_resource
  before_action :authorize_create, only: [:create]

  def create
    authorize! :create, @datastream_upload
    @datastream_upload.user = current_user
    if @datastream_upload.valid?
      Resque.enqueue(DatastreamUploadJob,
                     'basepath' => @datastream_upload.basepath,
                     'batch_user' => current_user.user_key,
                     'checksum_file' => @datastream_upload.checksum_file,
                     'checksum_location' => @datastream_upload.checksum_location,
                     'collection_id' => @datastream_upload.collection_id,
                     'datastream_name' => @datastream_upload.datastream_name,
                     'subpath' => @datastream_upload.subpath
                    )
      render "queued"
    else
      render "new"
    end
  end

  private

  def create_params
    params.require(:datastream_upload).permit(:basepath, :checksum_file, :checksum_location, :collection_id,
                                              :datastream_name, :subpath)
  end

  def authorize_create
    if (collection_id = @datastream_upload.collection_id).present?
      if can?(:upload, collection_id)
        current_ability.can :create, DatastreamUpload, collection_id: collection_id
      else
        current_ability.cannot :create, DatastreamUpload, collection_id: collection_id
      end
    end
  end

end
