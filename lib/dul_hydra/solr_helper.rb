module DulHydra::SolrHelper
  
  def af_model_filter(solr_params, user_params)
    solr_params[:fq] ||= []
    solr_params[:fq] << "+active_fedora_model_s:#{user_params[:model]}"
  end

end
