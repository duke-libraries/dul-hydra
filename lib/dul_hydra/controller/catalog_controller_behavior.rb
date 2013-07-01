module DulHydra::Controller
  module CatalogControllerBehavior
    extend ActiveSupport::Concern

    included do
      layout 'application', :only => :show
      layout 'blacklight', :except => :show
    end

    def show
      get_document
      get_children
    end

    protected

    def get_document
      @document = get_solr_response_for_doc_id[1]
    end
    
    def get_children
      get_children_search_results if @document.has_children?
    end

    def get_children_search_results
      configure_blacklight_for_children
      @response, @documents = get_search_results(params, {q: children_query})
    end

    def configure_blacklight_for_children
      blacklight_config.configure do |config|
        # Clear sort fields
        config.sort_fields.clear
        # Add custom sort fields for this query
        config.add_sort_field "#{DulHydra::IndexFields::IDENTIFIER} asc", label: 'Identifier'
        config.add_sort_field "#{DulHydra::IndexFields::TITLE} asc", label: 'Title'
        # XXX Not sure this is necessary
        config.default_sort_field = "#{DulHydra::IndexFields::IDENTIFIER} asc"
        config.qt = "standard"
      end    
    end

    def children_query
      # XXX We may want to index the child relationship predicate
      field = case
              when @document.active_fedora_model == "Collection"
                DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION
              when @document.active_fedora_model == "Item"
                DulHydra::IndexFields::IS_PART_OF
              end
      "#{field}:#{ActiveFedora::SolrService.escape_uri_for_query(@document.internal_uri)}"
    end

  end
end
