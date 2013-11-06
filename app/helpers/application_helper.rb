module ApplicationHelper

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

  def render_object_title
    current_object.title_display rescue "#{current_object.class.to_s} #{current_object.pid}"
  end

  def bootstrap_icon(icon)
    content_tag :i, "", class: "icon-#{icon}"
  end

  def permission_icon(perm)
    case
    when perm[:name] == Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      bootstrap_icon("globe")
    # when perm[:name] == Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
      # Duke icon
    when perm[:type] == :group
      (bootstrap_icon("user")*2).html_safe
    when perm[:type] == :user
      bootstrap_icon("user")
    end
  end

  def permission_name(perm)
    case
    when perm[:name] == Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      "Public"
    when perm[:name] == Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
      "Duke Community"
    else
      perm[:name]
    end
  end

  def render_object_identifier
    if current_object.identifier.respond_to?(:join)
      current_object.identifier.join("<br />")
    else
      current_object.identifier
    end
  end

  def render_object_date(date)
    format_date(DateTime.strptime(date, "%Y-%m-%dT%H:%M:%S.%LZ"))
  end

  def render_breadcrumb(crumb)
    truncate crumb.title, separator: ' '
  end

  def render_tab(tab)
    content_tag :li do
      link_to(tab.label, "##{tab.css_id}", "data-toggle" => "tab")
    end
  end

  def render_tabs
    return if current_tabs.blank?
    current_tabs.values.inject("") { |output, tab| output << render_tab(tab) }.html_safe
  end

  def render_tab_content(tab)
    content_tag :div, class: "tab-pane", id: tab.css_id do
      render partial: tab.partial, locals: {tab: tab}
    end
  end

  def render_tabs_content
    return if current_tabs.blank?
    current_tabs.values.inject("") { |output, tab| output << render_tab_content(tab) }.html_safe
  end

  def render_object_state
    case
    when current_object.state == 'A'
      render_label "Active", "info"
    when current_object.state == 'I'
      render_label "Inactive", "warning"
    when current_object.state == 'D'
      render_label "Deleted", "important"
    end
  end

  def render_last_fixity_check_outcome
    outcome = current_document.last_fixity_check_outcome
    if outcome.present?
      label = outcome == "success" ? "success" : "important"
      render_label outcome.capitalize, label
    end
  end

  def render_content_size(document)
    number_to_human_size(document.content_size) rescue nil
  end

  def render_content_type_and_size(document)
    "#{document.content_mime_type} #{render_content_size(document)}"
  end

  def render_download_link(args = {})
    document = args[:document]
    return unless document
    label = args.fetch(:label, "Download")
    css_class = args.fetch(:css_class, "")
    css_id = args.fetch(:css_id, "download-#{document.safe_id}")
    link_to label, download_object_path(document.id), :class => css_class, :id => css_id
  end
  
  def render_download_icon(args = {})
    label = content_tag(:i, "", :class => "icon-download-alt")
    render_download_link args.merge(:label => label)
  end

  def render_document_title
    current_document.title
  end

  def render_document_thumbnail(document, linked = false)
    src = document.has_thumbnail? ? thumbnail_object_path(document.id) : default_thumbnail
    thumbnail = image_tag(src, :alt => "Thumbnail", :class => "img-polaroid thumbnail")
    if linked && can?(:read, document)
      link_to thumbnail, object_path(document)
    else
      thumbnail
    end
  end

  def render_document_summary(document)
    render partial: 'document_summary', locals: {document: document}
  end

  def render_document_summary_association(document)
    association, label = case document.active_fedora_model
                         when "Attachment"
                           [:is_attached_to, "Attached to"]
                         when "Item"
                           [:is_member_of_collection, "Member of"]
                         when "Component"
                           [:is_part_of, "Part of"]
                         end
    if association && label
      associated_doc = get_associated_document(document, association)
      if associated_doc
        render partial: 'document_summary_association', locals: {label: label, document: associated_doc}
      end
    end
  end

  def get_associated_document(document, association)
    associated_pid = document.association(association)
    get_solr_response_for_field_values(:id, associated_pid)[1].first if associated_pid
  end

  def link_to_associated(document_or_object, label = nil)
    label ||= document_or_object.title rescue document_or_object.id
    if can? :read, document_or_object
      link_to label, object_path(document_or_object.id)
    else
      label
    end
  end

  def link_to_fcrepo_view(dsid = nil)
    path = dsid ? fcrepo_admin.object_datastream_path(current_object, dsid) : fcrepo_admin.object_path(current_object)
    link_to "Fcrepo View", path
  end

  def format_date(date)
    date.to_formatted_s(:db) if date
  end

  def effective_permissions(object)
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

  def display_permissions(type)
    groups = current_object.send("#{type}_groups")
    return :public if groups.include?("public")
    return :registered if groups.include?("registered")
    {groups: groups, users: current_object.send("#{type}_users")}
  end

  def display_inherited_permissions(type)
    policy_pid = current_ability.policy_pid_for(current_object.pid)    
    groups = current_ability.send("#{type}_groups_from_policy", policy_pid)
    return :public if groups.include?("public")
    return :registered if groups.include?("registered")
    {groups: groups, users: current_ability.send("#{type}_persons_from_policy", policy_pid)}
  end

  def inheritable_permissions(object)
    object.default_permissions
  end

  def event_outcome_label(pe)
    content_tag :span, pe.event_outcome.capitalize, :class => "label label-#{pe.success? ? 'success' : 'important'}"
  end

  def render_document_model_and_id(document)
    "#{document.active_fedora_model} #{document.id}"
  end

  private

  def render_label(text, label)
    content_tag :span, text, :class => "label label-#{label}"
  end

  def default_thumbnail
    'dul_hydra/no_thumbnail.png'
  end

end
