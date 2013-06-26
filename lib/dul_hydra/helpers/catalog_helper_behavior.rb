module DulHydra::Helpers
  module CatalogHelperBehavior
    
    def internal_uri_to_pid(args)
      ActiveFedora::Base.pids_from_uris(args[:document][args[:field]])
    end

    def internal_uri_to_link(args)
      pid = internal_uri_to_pid(args).first
      # Depends on Blacklight::SolrHelper#get_solr_response_for_doc_id 
      # having been added as a helper method to CatalogController
      response, doc = get_solr_response_for_doc_id(pid)
      # XXX This is not consistent with DulHydra::Models::Base#title_display
      title = doc.nil? ? pid : doc.fetch(DulHydra::IndexFields::TITLE, pid)
      link_to(title, catalog_path(pid), :class => "parent-link").html_safe
    end

    def display_structure(structure)
      display = ""
      if structure.has_key?("div")
        pids = walk_structure_div(structure["div"], "pids", [])
        structure_contents_info = get_structure_contents_info(pids)
        walk_structure_div(structure["div"], "display", display, structure_contents_info)
      end
      return display
    end
    
    def walk_structure_div(structure_div, mode, collector, structure_contents_info=nil)
      structure_div.each do |div|
        collector << div["label"] if mode.eql?("display") && div.has_key?("label")
        if div.has_key?("div")
          walk_structure_div(div["div"], mode, collector, structure_contents_info)
        else
          walk_structure_pids(div["pids"], mode, collector, structure_contents_info)
        end
      end
      return collector
    end
    
    def walk_structure_pids(structure_pids, mode, collector, structure_contents_info=nil)
      collector << "<ul>" if mode.eql?("display")
      structure_pids.each do |pid|
        collector << case mode
        when "pids"
          pid["pid"]
        when "display"
          "<li>" << link_to(structure_contents_info[pid["pid"]][DulHydra::IndexFields::TITLE], fcrepo_admin.object_path(pid["pid"])) << " [" << pid["use"] << "]</li>"
        end
      end
      collector << "</ul>" if mode.eql?("display")
      return collector
    end
    
    def get_structure_contents_info(pids)
      structure_contents_info = {}
      query = ActiveFedora::SolrService.construct_query_for_pids(pids)
      contents_docs = ActiveFedora::SolrService.query(query, :rows => 999)
      contents_docs.each do |contents_doc|
        structure_contents_info[contents_doc["id"]] = contents_doc
      end
      return structure_contents_info
    end

    def render_thumbnail(document = @document)
      src = document.has_thumbnail? ? thumbnail_path(document) : 'dul_hydra/no_thumbnail.png'
      link_to image_tag(src, :alt => "Thumbnail", :class => "img-polaroid thumbnail"), catalog_path(document.id)
    end

    def render_document_breadcrumbs
      render partial: 'show_breadcrumbs', locals: {breadcrumbs: document_breadcrumbs}
    end

    def render_sidebar_for_model
      begin
        partial = "show_%s_sidebar" % document_partial_name(@document)
        return render partial: partial, locals: {document: @document}
      rescue ActionView::MissingTemplate
        nil
      end
    end

    def render_children
      title = case
              when @document.active_fedora_model == "Collection"
                "Items"
              when @document.active_fedora_model == "Item"
                "Components"
              end
      render partial: 'show_children', locals: {title: title}
    end

    def render_object_state
      case
      when @document.object_state == 'A'
        text = "Active"
        label = "info"
      when @document.object_state == 'I'
        text = "Inactive"
        label = "warning"
      when @document.object_state == 'D'
        text = "Deleted"
        label = "important"
      end
      render_label(text, label)
    end

    def render_last_fixity_check_outcome
      outcome = @document.last_fixity_check_outcome
      label = outcome == "success" ? "success" : "important"
      render_label(outcome, label)
    end

    private

    def render_label(text, label)
      content_tag :span, text, :class => "label label-#{label}"
    end

    def document_breadcrumbs(doc = @document, breadcrumbs = [])
      breadcrumbs << doc
      document_breadcrumbs(get_solr_response_for_doc_id(doc.parent_pid)[1], breadcrumbs) if doc.has_parent?
      breadcrumbs
    end
    
  end
end
