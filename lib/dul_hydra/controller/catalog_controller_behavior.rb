module DulHydra::Controller
  module CatalogControllerBehavior

    def show
      @response, @document = get_solr_response_for_doc_id
      #setup_next_and_previous_documents
      if ["Collection", "Item"].include? @document.active_fedora_model
        self.solr_search_params_logic += [:add_children_query]
        @children_response, @children_documents = get_search_results
      end
    end

    protected

    def add_children_query(solr_params, user_params)
      field = case
              when @document.active_fedora_model == "Collection"
                DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION
              when @document.active_fedora_model == "Item"
                DulHydra::IndexFields::IS_PART_OF
              end
      solr_params[:q] = "#{field}:#{ActiveFedora::SolrService.escape_uri_for_query(@document.internal_uri)}"
      solr_params[:qt] = "standard"
    end

  end
end
