module ApplicationHelper

  def title_display_solr_value(solr_doc)
    solr_doc[ActiveFedora::SolrService.solr_name(:title, :displayable)]
  end

end
