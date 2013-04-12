module PreservationEventsHelper

  def pe_solr_field_value(solr_doc, field)
    if field == :event_date_time
      solr_doc.get(ActiveFedora::SolrService.solr_name(field, :sortable, type: :date))
    else
      solr_doc.get(ActiveFedora::SolrService.solr_name(field, :symbol))
    end
  end

end
