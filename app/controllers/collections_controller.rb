class CollectionsController < ApplicationController

  before_action do |controller|
    authorize! :create, Collection
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(params.require(:collection).permit(:title, :description))
    @collection.admin_policy = AdminPolicy.find(params.require(:admin_policy_id))
    @collection.set_initial_permissions(current_user)
    @collection.save!
    @collection.log_event(action: "create", user: current_user)
    flash[:success] = "New Collection created."
    redirect_to controller: 'objects', action: 'show', id: @collection
  rescue ActiveFedora::RecordInvalid, ActiveFedora::ObjectNotFoundError
    render :new
  end

end
