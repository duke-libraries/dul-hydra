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

  end
end
