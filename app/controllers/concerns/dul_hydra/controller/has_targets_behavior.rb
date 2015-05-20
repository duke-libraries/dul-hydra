module DulHydra
  module Controller
    module HasTargetsBehavior

      def targets
        get_targets
      end

      protected

      def get_targets
        configure_blacklight_for_targets
        query = current_object.association_query(:targets)
        @response, @document_list = get_search_results(params, {q: query})
      end

      def configure_blacklight_for_targets
        blacklight_config.configure do |config|
          config.sort_fields.clear
          config.add_sort_field "#{Ddr::IndexFields::LOCAL_ID} asc", label: "Local ID"
          config.add_sort_field "#{Ddr::IndexFields::TITLE} asc", label: "Title"
        end
      end

    end
  end
end
