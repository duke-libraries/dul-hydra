module DulHydra::SolrHelper
  
  def af_model_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+#{DulHydra::IndexFields::ACTIVE_FEDORA_MODEL}:#{user_params[:model]}"
  end

  def preservation_events_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+#{DulHydra::IndexFields::IS_PRESERVATION_EVENT_FOR}:\"info:fedora/#{user_params[:object_id]}\""
  end

end
