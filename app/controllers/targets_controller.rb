class TargetsController < ApplicationController

  include Blacklight::SolrHelper
  include DulHydra::SolrHelper
    
  def index
    #query = "id:#{ActiveFedora::SolrService.escape_uri_for_query(params[:object_id])}"
    #results = ActiveFedora::SolrService.query(query)
    #doc = SolrDocument.new(results[0])
    response, doc = get_solr_response_for_doc_id(params[:object_id])
    @title = doc.get(:title_display)
    self.solr_search_params_logic += [:targets_filter]
    @response, @document_list = get_search_results
  end
    
end
