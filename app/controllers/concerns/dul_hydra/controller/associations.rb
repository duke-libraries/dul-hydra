module DulHydra
  module Controller
    module Associations
      extend ActiveSupport::Concern

      included do
        include Blacklight::Base
        copy_blacklight_config_from CatalogController

        before_action :configure_blacklight_for_related_objects, only: :show

        helper_method :object_attachments
        helper_method :get_solr_response_for_field_values
      end

      protected

      SolrResult = Struct.new(:response, :documents)

      def configure_blacklight_for_related_objects
        blacklight_config.configure do |config|
          config.sort_fields.clear
          config.add_sort_field "#{DulHydra::IndexFields::IDENTIFIER} asc", label: 'Identifier'
          config.add_sort_field "#{DulHydra::IndexFields::TITLE} asc", label: 'Title'
        end
      end

      def object_children
        return @object_children if @object_children
        if current_object.can_have_children?
          @object_children = SolrResult.new(*get_search_results(params, children_query_params))
          # For compatibility with Blacklight partials and helpers that paginate results
          @response = @object_children.response
          @documents = @object_children.documents
          @partial_path_templates = ["catalog/index_default"]
        end
        @object_children
      end

      def children_query_params
        {q: current_object.children_query}
      end

      def attachments_query_params
        {q: current_object.attachments.send(:construct_query)}
      end

      def object_attachments
        return @object_attachments if @object_attachments
        if current_object.can_have_attachments?
          @object_attachments = SolrResult.new(*get_search_results(params, attachments_query_params))
          # For compatibility with Blacklight partials and helpers
          @partial_path_templates = ["catalog/index_default"]
        end
        @object_attachments
      end

    end
  end
end
