class ChildrenController < ApplicationController

  include Blacklight::SolrHelper
  include DulHydra::SolrHelper
    
  def index
    response, document = get_solr_response_for_doc_id(params[:object_id])
    @title = document.get(DulHydra::IndexFields::TITLE)
    if document[DulHydra::IndexFields::CONTENT_METADATA_PARSED]
      @content_metadata = document.parsed_content_metadata
    else
      self.solr_search_params_logic += [:children_filter]
      @response, @document_list = get_search_results
    end
  end
    
end
