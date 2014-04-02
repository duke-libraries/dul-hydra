module DulHydra
  module Controller
    module CurrentObject
      extend ActiveSupport::Concern

      included do
        helper_method :current_object
        helper_method :current_document
      end

      include Blacklight::Base

      def current_object
        @current_object ||= case params[:action]
                            when "new", "create", "edit", "update"
                              resource
                            when "show"
                              ActiveFedora::SolrService.reify_solr_result(current_document)
                            else
                              ActiveFedora::Base.find(params[:id], cast: true)
                            end
      end

      def current_document
        @document ||= get_solr_response_for_doc_id[1]
      end

    end
  end
end
