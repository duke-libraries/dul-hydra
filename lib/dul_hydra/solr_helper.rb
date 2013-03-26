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
    solr_params[:sort] = ["title_display_sort asc"]
  end

  def children_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    object_uri = ActiveFedora::SolrService.escape_uri_for_query("info:fedora/#{user_params[:object_id]}")
    solr_params[:fq] << "+is_member_of_s:#{object_uri} OR is_member_of_collection_s:#{object_uri} OR is_part_of_s:#{object_uri}"
    solr_params[:sort] = ["title_display_sort asc"]
  end

end
