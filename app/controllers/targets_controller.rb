class TargetsController < ApplicationController

  include Blacklight::SolrHelper
  include DulHydra::SolrHelper
    
  def index
    self.solr_search_params_logic += [:targets_filter]
    @title = params[:object_id]
    @response, @document_list = get_search_results
    puts @response
  end
    
end
