module ApplicationHelper

  def title_display_solr_value(solr_doc)
    solr_doc[DulHydra::IndexFields::TITLE]
  end

  def object_has_preservation_events?
    !@object.is_a?(PreservationEvent) && @object.is_a?(DulHydra::Models::HasPreservationEvents)
  end

  def object_children_nav_item
    if @object.is_a?(DulHydra::Models::HasContentMetadata) && @object.datastreams[DulHydra::Datastreams::CONTENT_METADATA].has_content?
      content_tag :li do 
        link_to_unless_current "Children", children_path(@object)
      end
    elsif @object.reflections.has_key?(:children)
      content_tag :li do
        link_to_unless_current "Children", fcrepo_admin.object_association_path(@object, 'children')
      end
    end
  end

end
