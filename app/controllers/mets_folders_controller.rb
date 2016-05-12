class MetsFoldersController < ApplicationController

  before_filter :new_mets_folder, :only => [ :new, :create ]

  load_and_authorize_resource class: METSFolder

  def new_mets_folder
    @mets_folder = METSFolder.new(mets_folder_params)
    @mets_folder.base_path = DulHydra.mets_folder_base_path
  end

  def create
    @mets_folder.user = current_user
    if @mets_folder.save
      redirect_to action: :show, id: @mets_folder
    else
      render :new
    end
  end

  def show
    @inspection_results = InspectMETSFolder.new(@mets_folder).call
  end

  def procezz
    @inspection_results = InspectMETSFolder.new(@mets_folder).call
    BuildBatchFromMETSFolder.new(
      batch_user: current_user,
      filesystem: @inspection_results.filesystem,
      collection: ActiveFedora::Base.find(@mets_folder.collection_id),
      batch_name: 'METS Folder Update',
      batch_description: @inspection_results.filesystem.root.name,
      display_formats: METSFolderConfiguration.new.display_format_config
      ).call
    redirect_to :controller => :batches, :action => :index
  end

  private

  def mets_folder_params
    params.require(:mets_folder).permit(:collection_id, :user, :base_path, :sub_path)
  end

end
