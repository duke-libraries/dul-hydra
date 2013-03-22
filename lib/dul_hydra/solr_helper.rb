module DulHydra::SolrHelper
  
  def af_model_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+active_fedora_model_s:#{user_params[:model]}"
  end

  def preservation_events_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+is_preservation_event_for_s:\"info:fedora/#{user_params[:object_id]}\""
  end

  def targets_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+is_external_target_for_s:\"info:fedora/#{user_params[:object_id]}\""
#    solr_params[:sort] = ["title_display asc"]
  end

end
