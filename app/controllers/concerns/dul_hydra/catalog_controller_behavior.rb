module DulHydra
  module CatalogControllerBehavior
    extend ActiveSupport::Concern

    included do
      layout 'application', :only => :show
      layout 'blacklight', :except => :show
    end

    def show
      get_document
      get_object
      respond_to do |format|
        format.html do
          get_children
          get_collection_info
        end
        format.csv do
          render(text: "Not valid for this object type", status: 404) unless @object.is_a?(Collection)
          send_data(collection_report, type: "text/csv")
        end
      end
    end

    protected

    def get_document
      @document = get_solr_response_for_doc_id[1]
    end

    def get_object
      @object = ActiveFedora::SolrService.reify_solr_result(@document)
    end
    
    def get_children
      if @object.is_a?(DulHydra::HasChildren)
        configure_blacklight_for_children
        @response, @documents = get_search_results(params, {q: @object.children_query})
      end
    end

    def collection_report
      CSV.generate do |csv|
        csv << DulHydra.collection_report_fields.collect {|f| f.to_s.upcase}
        get_collection_components[1].each do |doc|
          csv << DulHydra.collection_report_fields.collect {|f| doc.send(f)}
        end
      end
    end

    def get_collection_components
      get_search_results(params, @object.components_query)
    end

    def get_collection_info
      if @object.is_a?(Collection)
        response, documents = get_collection_components
        @components = response.total
        @total_file_size = documents.collect {|doc| doc.datastreams["content"]["dsSize"] || 0 }.inject(:+)
      end
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

  end
end
