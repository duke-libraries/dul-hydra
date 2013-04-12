class ChildrenController < ApplicationController

  include Blacklight::SolrHelper
  include DulHydra::SolrHelper
    
  def index
    response, document = get_solr_response_for_doc_id(params[:object_id])
    @title = document.get(ActiveFedora::SolrService.solr_name(:title, :displayable))
    if document[ActiveFedora::SolrService.solr_name(:content_metadata_parsed, :symbol)]
      @content_metadata = document.parsed_content_metadata
    else
      self.solr_search_params_logic += [:children_filter]
      @response, @document_list = get_search_results
    end
  end
    
end
