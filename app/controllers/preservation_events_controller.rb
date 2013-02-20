class PreservationEventsController < ApplicationController
  
  include Blacklight::SolrHelper
  include DulHydra::SolrHelper
    
  def index
    self.solr_search_params_logic += [:preservation_events_filter]
    @title = "Preservation Events for #{params[:object_id]}"
    @response, @document_list = get_search_results
  end
    
end