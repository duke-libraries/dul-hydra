module DulHydra::SolrHelper
  
  def af_model_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+#{DulHydra::IndexFields::ACTIVE_FEDORA_MODEL}:#{user_params[:model]}"
  end

  def preservation_events_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+#{DulHydra::IndexFields::IS_PRESERVATION_EVENT_FOR}:\"info:fedora/#{user_params[:id]}\""
  end

  def children_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    object_uri = ActiveFedora::SolrService.escape_uri_for_query("info:fedora/#{user_params[:object_id]}")
    solr_params[:fq] << "+(#{DulHydra::IndexFields::IS_MEMBER_OF}:#{object_uri} OR #{DulHydra::IndexFields::IS_MEMBER_OF_COLLECTION}:#{object_uri} OR #{DulHydra::IndexFields::IS_PART_OF}:#{object_uri})"
    solr_params[:sort] = ["#{DulHydra::IndexFields::TITLE} asc"]
  end

end
