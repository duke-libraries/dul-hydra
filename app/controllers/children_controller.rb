class ChildrenController < ApplicationController

  include Blacklight::SolrHelper
  include DulHydra::SolrHelper
  include FcrepoAdmin::Controller::ControllerBehavior

  before_filter :load_and_authorize_object

  layout 'fcrepo_admin/objects'
    
  def index
    unless @object.is_a?(DulHydra::Models::HasContentMetadata) && @object.datastreams[DulHydra::Datastreams::CONTENT_METADATA].has_content?
      redirect_to :controller => 'fcrepo_admin/associations', :action => 'show', :object_id => @object, :id => 'children', :use_route => 'fcrepo_admin'
    end
  end
    
end
