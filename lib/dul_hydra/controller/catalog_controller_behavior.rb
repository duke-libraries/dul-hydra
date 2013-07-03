module DulHydra::Controller
  module CatalogControllerBehavior
    extend ActiveSupport::Concern

    included do
      layout 'application', :only => :show
      layout 'blacklight', :except => :show
    end

    def show
      get_document # XXX Phase out and use object only
      load_and_authorize_object
      get_children
    end

    protected

    def get_document
      @document = get_solr_response_for_doc_id[1]
    end

    def load_and_authorize_object
      load_object
      authorize_object
    end

    def load_object
      pid = params[:object_id] || params[:id]
      begin
        @object = ActiveFedora::Base.find(pid, :cast => true)
      rescue ActiveFedora::ObjectNotFoundError
        render :text => "Object not found", :status => 404
      end
    end

    def authorize_object
      authorize! params[:action].to_sym, @object
    end
    
    def get_children
      get_children_search_results if @object.is_a?(DulHydra::Models::HasChildren)
    end

    def get_children_search_results
      configure_blacklight_for_children
      @response, @documents = get_search_results(params, {q: @object.children_query})
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
