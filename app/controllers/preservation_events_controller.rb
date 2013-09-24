class PreservationEventsController < ApplicationController
  
  include Blacklight::Catalog

  layout 'application'

  def index
    @document = get_solr_response_for_doc_id[1]
    @object = ActiveFedora::SolrService.reify_solr_result(@document)
    authorize! :read, @object
    @preservation_events = @object.preservation_events
  end

  def show
    @preservation_event = PreservationEvent.find(params[:id])
    authorize! :read, @preservation_event
    respond_to do |format|
      format.html
      format.xml
    end
  end

end
