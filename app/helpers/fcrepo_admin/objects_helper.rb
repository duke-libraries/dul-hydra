module FcrepoAdmin
  module ObjectsHelper
    include FcrepoAdmin::Helpers::ObjectsHelperBehavior

    def render_object_thumbnail
      if @object.is_a?(DulHydra::Models::HasThumbnail) && @object.has_thumbnail?
        render :partial => 'fcrepo_admin/objects/thumbnail', :locals => {:object => @object}
      end
    end

    def pe_solr_field_value(solr_doc, field)
      solr_doc.get(DulHydra::IndexFields.const_get(field.to_s.upcase))
    end

    def custom_object_nav_item(item)
      case
      when item == :preservation_events
        if @object.has_preservation_events?
          link_to_unless_current t("fcrepo_admin.object.nav.items.preservation_events"), preservation_events_path(@object)
        end
      end
    end

  end
end
