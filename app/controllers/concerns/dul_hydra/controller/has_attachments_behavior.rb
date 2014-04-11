module DulHydra
  module Controller
    module HasAttachmentsBehavior
      extend ActiveSupport::Concern

      included do
        self.tabs << :tab_attachments
        before_action :get_attachments, only: :show
      end

      def get_attachments
        query = current_object.association_query(:attachments)
        response, @attachments = get_search_results(params, {q: query})        
      end

    end
  end
end
