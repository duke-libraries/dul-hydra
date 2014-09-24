module Blacklight::SolrHelper

  def query_count(user_params = params || {}, extra_controller_params = {})
    query_solr(user_params, extra_controller_params.merge(rows: 0)).total
  end

end
