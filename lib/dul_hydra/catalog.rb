module DulHydra::Catalog

  def model_index
    @title = params[:model].pluralize
    @solr_response, @document_list = get_solr_response_for_field_values(:active_fedora_model_s, params[:model])
  end

end
