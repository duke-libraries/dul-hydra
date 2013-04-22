class TargetsController < ApplicationController

  include Blacklight::SolrHelper
  include DulHydra::SolrHelper
    
  def index
    response, doc = get_solr_response_for_doc_id(params[:object_id])
    @title = doc.get(DulHydra::IndexFields::TITLE)
    self.solr_search_params_logic += [:targets_filter]
    @response, @document_list = get_search_results
  end
    
end
