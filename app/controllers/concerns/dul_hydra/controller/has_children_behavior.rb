module DulHydra
  module Controller
    module HasChildrenBehavior
      extend ActiveSupport::Concern

      included do
        copy_blacklight_config_from CatalogController        
        before_action :get_children, only: :show
      end

      protected

      def get_children
        configure_blacklight_for_children
        # Set instance vars for compatibility with Blacklight helpers and views
        query = current_object.association_query(:children)
        @response, @document_list = get_search_results(params, {q: query})
      end

      def configure_blacklight_for_children
        blacklight_config.configure do |config|
          config.sort_fields.clear
          config.add_sort_field "#{DulHydra::IndexFields::IDENTIFIER} asc", label: "Identifier"
          config.add_sort_field "#{DulHydra::IndexFields::TITLE} asc", label: "Title"
        end
      end

    end
  end
end
