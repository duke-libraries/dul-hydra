module DulHydra
  module Controller
    module HasAttachmentsBehavior

      def attachments
        get_attachments
      end

      protected

      def get_attachments
        configure_blacklight_for_attachments
        query = current_object.association_query(:attachments)
        @response, @document_list = get_search_results(params, {q: query})
      end

      def configure_blacklight_for_attachments
        blacklight_config.configure do |config|
          config.sort_fields.clear
          config.add_sort_field "#{Ddr::IndexFields::TITLE} asc", label: "Title"
        end
      end

    end
  end
end
