class PreservationEventsController < CatalogController
  
  include DulHydra::SolrHelper
  include FcrepoAdmin::Controller::ControllerBehavior

  layout 'fcrepo_admin/objects'

  before_filter :load_and_authorize_object
    
  def index
    self.solr_search_params_logic += [:preservation_events_filter]
    @response, @document_list = get_search_results
  end
    
end
