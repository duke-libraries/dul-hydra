module ApplicationHelper

  def title_display_solr_value(solr_doc)
    solr_doc[DulHydra::IndexFields::TITLE]
  end

  def has_preservation_events?(object)
    !object.is_a?(PreservationEvent) && object.is_a?(DulHydra::Models::HasPreservationEvents)
  end

end
