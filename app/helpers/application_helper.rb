module ApplicationHelper

  def title_display_solr_value(solr_doc)
    solr_doc[DulHydra::IndexFields::TITLE]
  end

  def object_has_preservation_events?
    !@object.is_a?(PreservationEvent) && @object.is_a?(DulHydra::Models::HasPreservationEvents)
  end

end
