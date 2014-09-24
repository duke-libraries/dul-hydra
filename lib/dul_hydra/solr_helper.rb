module DulHydra::SolrHelper
  
  def af_model_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+#{DulHydra::IndexFields::ACTIVE_FEDORA_MODEL}:#{user_params[:model]}"
  end

end
