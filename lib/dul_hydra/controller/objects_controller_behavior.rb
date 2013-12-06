module DulHydra::Controller
  module ObjectsControllerBehavior
    extend ActiveSupport::Concern

    included do
      include Blacklight::Base
      helper_method :current_object
      helper_method :current_document
      helper_method :get_solr_response_for_field_values
    end

    protected 

    def current_object
      @object ||= current_document ? ActiveFedora::SolrService.reify_solr_result(current_document) : ActiveFedora::Base.find(params[:id], cast: true)
    end

    def current_document
      @document ||= get_solr_response_for_doc_id[1]
    end

  end
end
