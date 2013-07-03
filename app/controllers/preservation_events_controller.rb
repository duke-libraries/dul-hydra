class PreservationEventsController < CatalogController
  
  layout 'application'

  PreservationEventsController.solr_search_params_logic.delete(:exclude_unwanted_models)
  before_filter :enforce_show_permissions, :only => :index

  def index
    get_document
    get_preservation_events
  end

  protected

  def configure_blacklight_for_preservation_events
    blacklight_config.configure do |config|
      config.sort_fields.clear
      config.add_sort_field "#{DulHydra::IndexFields::EVENT_DATE_TIME} desc"
      config.qt = "standard"
    end
  end
  
  def get_preservation_events
    configure_blacklight_for_preservation_events
    @response, @documents = get_search_results(params, {q: preservation_events_query})
  end

  def preservation_events_query
    ActiveFedora::SolrService.construct_query_for_rel(:is_preservation_event_for => @document.internal_uri)
  end

end
