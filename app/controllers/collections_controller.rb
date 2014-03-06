class CollectionsController < ApplicationController

  include DulHydra::EventLogBehavior
  log_actions :create

  before_action { |controller| authorize! :create, Collection }

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(params.require(:collection).permit(:title, :description))
    @collection.admin_policy = AdminPolicy.find(params.require(:admin_policy_id))
    @collection.set_initial_permissions(current_user)
    @collection.save!
    flash[:success] = "New Collection created."
    redirect_to controller: 'objects', action: 'show', id: @collection
  rescue ActiveFedora::RecordInvalid, ActiveFedora::ObjectNotFoundError
    render :new
  end

end
