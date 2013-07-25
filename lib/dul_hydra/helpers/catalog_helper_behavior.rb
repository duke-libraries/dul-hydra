require 'dul_hydra'

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

    def render_object_title
      @object.title_display rescue "#{@object.class.to_s} #{@object.pid}"
    end

    def render_breadcrumbs
      render partial: 'show_breadcrumbs', locals: {breadcrumbs: document_breadcrumbs}
    end

    def render_breadcrumb(crumb)
      truncate crumb.title, separator: ' '
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

    def show_tabs
      return @show_tabs if @show_tabs
      @show_tabs = []
      @show_tabs << {
        label: @documents.blank? ? "Content" : @documents.first.active_fedora_model.pluralize,
        partial: @documents.blank? ? 'show_content' : 'show_children',
        id: 'tab-default', 
        active: true
      }
      @show_tabs << {label: 'Metadata', partial: 'show_metadata', id: 'tab-metadata'} if @object.describable?
      @show_tabs << {label: 'Collection Info', partial: 'show_collection_info', id: 'tab-collection-info'} if @object.is_a?(Collection)
      @show_tabs << {label: 'Permissions', partial: 'show_permissions', id: 'tab-permissions'}
      @show_tabs
    end

    def render_show_tab(tab)
      opts = tab[:active] ? {class: "active"} : {}
      content_tag :li, opts do
        link_to tab[:label], "#" + tab[:id], "data-toggle" => "tab" 
      end
    end

    def render_show_tab_content(tab)
      css_class = tab[:active] ? "tab-pane active" : "tab-pane"
      content_tag :div, class: css_class, id: tab[:id] do
        render(tab[:partial])
      end
    end

    def metadata_fields
      DulHydra.metadata_fields
    end

    def metadata_field_values(field)
      @object.send(field)
    end

    def metadata_field_label(field)
      field.to_s.capitalize
    end

    def render_object_state
      case
      when @object.state == 'A'
        text = "Active"
        label = "info"
      when @object.state == 'I'
        text = "Inactive"
        label = "warning"
      when @object.state == 'D'
        text = "Deleted"
        label = "important"
      end
      render_label(text, label)
    end

    def render_last_fixity_check_outcome
      outcome = @document.last_fixity_check_outcome
      return nil unless outcome
      label = outcome == "success" ? "success" : "important"
      render_label(outcome.capitalize, label)
    end

    def render_content_size(document = @document)
      number_to_human_size(document.content_size) rescue nil
    end

    def render_content_type_and_size(document = @document)
      "#{document.content_mime_type} #{render_content_size(document)}"
    end

    def render_download_link(args = {})
      document = args.fetch(:document, @document)
      label = args.fetch(:label, "Download")
      css_class = args.fetch(:css_class, "")
      css_id = args.fetch(:css_id, "download-#{document.id.sub(/:/, "-")}")
      link_to label, download_path(document.id), :class => css_class, :id => css_id
    end
    
    def render_download_icon(args = {})
      label = content_tag(:i, "", :class => "icon-download-alt")
      render_download_link args.merge(:label => label)
    end

    def render_thumbnail(document_or_object)
      src = document_or_object.has_thumbnail? ? thumbnail_path(document_or_object.id) : default_thumbnail
      image_tag(src, :alt => "Thumbnail", :class => "img-polaroid thumbnail")
    end

    def format_date(date)
      date.to_formatted_s(:db) if date
    end

    def effective_permissions(object = @object)
      results = []
      permissions = current_ability.permissions_doc(object.pid)
      policy_pid = current_ability.policy_pid_for(object.pid)
      policy_permissions = policy_pid ? current_ability.policy_permissions_doc(policy_pid) : nil
      [:discover, :read, :edit].each do |access|
        [:individual, :group].each do |type|
          permissions.fetch(Hydra.config[:permissions][access][type], []).each do |name|
            results << {type: type, access: access, name: name, inherited: false}
          end
          if policy_permissions
            policy_permissions.fetch(Hydra.config[:permissions][:inheritable][access][type], []).each do |name|
              results << {type: type, access: access, name: name, inherited: true}
            end
          end
        end
      end
      results
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

    def default_thumbnail
      'dul_hydra/no_thumbnail.png'
    end
    
  end
end
