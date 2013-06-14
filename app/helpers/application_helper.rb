module ApplicationHelper

  def title_display_solr_value(solr_doc)
    solr_doc[DulHydra::IndexFields::TITLE]
  end

end
