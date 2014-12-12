module ApplicationHelper

  def internal_uri_to_pid(args)
    ActiveFedora::Base.pid_from_uri(args[:document][args[:field]])
  end

  def internal_uri_to_link(args)
    pid = internal_uri_to_pid(args).first
    # Depends on Blacklight::SolrHelper#get_solr_response_for_doc_id 
    # having been added as a helper method to CatalogController
    response, doc = get_solr_response_for_doc_id(pid)
    # XXX This is not consistent with Ddr::Models::Base#title_display
    title = doc.nil? ? pid : doc.fetch(Ddr::IndexFields::TITLE, pid)
    link_to(title, catalog_path(pid), :class => "parent-link").html_safe
  end

  def render_object_title
    current_document.title
  end

  def object_display_title(pid)
    if pid.present?
      begin
        object = ActiveFedora::Base.find(pid)
        if object.respond_to?(:title_display)
          object.title_display
        end
      rescue ActiveFedora::ObjectNotFoundError
        log.error("Unable to find #{pid} in repository")
      end
    end
  end
    
  def user_icon
    image_tag("silk/user.png", size: "16x16", alt: "user")
  end

  def group_icon(group = nil)
    case group
    when Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      public_icon
    else
      image_tag("silk/group.png", size: "16x16", alt: "group")
    end
  end

  def public_icon
    content_tag :span, nil, class: "glyphicon glyphicon-globe"
  end

  def group_display_name(group)
    case group
    when Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      "Public"
    when Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
      "Duke Community"
    else
      group
    end
  end

  def render_object_identifier
    if current_object.identifier.respond_to?(:join)
      current_object.identifier.join("<br />")
    else
      current_object.identifier
    end
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

  def render_event_outcome(outcome)
    label = outcome == Ddr::Events::Event::SUCCESS ? "success" : "danger"
    render_label outcome.capitalize, label
  end

  def render_content_type_and_size(document)
    "#{document.content_mime_type} #{document.content_size_human}"
  end

  def render_download_link(args = {})
    return unless args[:document]
    label = args.fetch(:label, "Download")
    link_to label, download_path(args[:document]), class: args[:css_class], id: args[:css_id]
  end
  
  def render_download_icon(args = {})
    label = content_tag(:span, "", class: "glyphicon glyphicon-download-alt")
    render_download_link args.merge(label: label)
  end

  def render_thumbnail(doc_or_obj, linked = false)
    src = doc_or_obj.has_thumbnail? ? thumbnail_path(doc_or_obj) : default_thumbnail(doc_or_obj)
    thumbnail = image_tag(src, :alt => "Thumbnail", :class => "img-thumbnail")
    if linked && can?(:read, doc_or_obj)
      link_to thumbnail, document_or_object_url(doc_or_obj)
    else
      thumbnail
    end
  end

  def render_document_summary(document)
    render partial: 'document_summary', locals: {document: document}
  end

  def format_date(date)
    if date
      date = Time.parse(date) if !date.respond_to?(:localtime)
      date.localtime.to_s
    end 
  end

  def render_permission_grantees(access)
    grantees = {
      users: current_object.send("#{access}_users"),
      groups: current_object.send("#{access}_groups")
    }
    render partial: 'permission_grantees', locals: {grantees: grantees}
  end

  def render_inherited_permission_grantees(access)
    grantees = {
      users: current_object.send("inherited_#{access}_users"),
      groups: current_object.send("inherited_#{access}_groups")
    }
    render partial: 'permission_grantees', locals: {grantees: grantees}
  end

  def render_default_permission_grantees(access)
    grantees = {
      users: current_object.send("default_#{access}_users"),
      groups: current_object.send("default_#{access}_groups")
    }
    render partial: 'permission_grantees', locals: {grantees: grantees}
  end

  def render_inherited_entities(type, access)
    if current_object.governable?
      inherited_entities = current_object.send("inherited_#{access}_#{type}s")
      render partial: 'inherited_permissions', locals: {inherited_entities: inherited_entities, type: type}
    end
  end

  def render_inherited_groups(access)
    render_inherited_entities("group", access)
  end

  def render_inherited_users(access)
    render_inherited_entities("user", access)
  end

  def event_outcome_label(event)
    if event.outcome
      label = event.success? ? 'success' : 'danger'
      content_tag :span, event.outcome.capitalize, class: "event-outcome label label-#{label}"
    end
  end

  def render_document_model_and_id(document)
    "#{document.active_fedora_model} #{document.id}"
  end

  def link_to_document_or_object(doc_or_obj, access = :read)
	link_to_if can?(access, doc_or_obj), doc_or_obj.title_display, document_or_object_url(doc_or_obj)
  end

  def link_to_create_model(model)
    link_to I18n.t("dul_hydra.#{model.underscore}.new_menu", default: model), controller: model.tableize, action: "new"
  end

  def document_or_object_url(doc_or_obj)
    url_for controller: doc_or_obj.controller_name, action: "show", id: doc_or_obj
  end

  def model_options_for_select(model, opts={})
    models = find_models_with_gated_discovery(model)
    if opts[:access]
      models = models.select { |m| can? opts[:access], m }
    end
    options = models.collect { |m| [m.title.is_a?(Array) ? m.title.first : m.title, m.pid] }
    options_for_select options, opts[:selected]
  end

  def create_menu_models
    session[:create_menu_models] ||= DulHydra.create_menu_models.select { |model| can? :create, model.constantize }
  end

  def manage_menu
    # By default, the session :manage_menu is empty
    # Signing into the :superuser cope will add Queue to the :manage_menu and signing out of that scope will remove it
    session[:manage_menu] ||= []
  end

  def cancel_button args={}
    return_to = args.delete(:return_to) || :back
    opts = {class: ["btn", "btn-danger", args.delete(:class)].compact.join(" ")}
    opts.merge! args
    link_to "Cancel", return_to, opts
  end

  def user_options_for_select(permission)
    options_for_select all_user_options, selected_user_options(permission)
  end

  def group_options_for_select(permission)
    options_for_select all_group_options, selected_group_options(permission)
  end

  def all_user_options
    @all_user_options ||= user_options(User.order(:last_name, :first_name))
  end

  def selected_user_options(permission)
    users = case params[:action]
            when "permissions" then current_object.send "#{permission}_users"
            when "default_permissions" then current_object.send "default_#{permission}_users"
            end
    users.collect { |u| user_option_value(u) }
  end

  def group_options(groups)
    groups.collect { |g| [group_option_text(g), group_option_value(g)] }
  end

  def all_group_options
    # TODO: List public first, then registered, then rest in alpha order (?)
    @all_group_options ||= group_options(group_service.groups)
  end

  def selected_group_options(permission)
    groups = case params[:action]
             when "permissions" then current_object.send "#{permission}_groups"
             when "default_permissions" then current_object.send "default_#{permission}_groups"
             end
    groups.collect { |g| group_option_value(g) }
  end

  def group_option_text(group_name)
    case group_name
    when Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
      "Public"
    when Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
      "Duke Community"
    else
      group_name
    end
  end

  def group_option_value(group_name)
    "group:#{group_name}"
  end

  def user_options(users)
    users.collect { |u| [user_option_text(u), user_option_value(u)] }
  end

  def user_option_text(user)
    user.display_name or user.user_key
  end

  def user_option_value(user_name)
    "user:#{user_name}"
  end

  def inherited_permissions_alert
    apo_link = link_to(current_object.admin_policy_id, collection_path(current_object.admin_policy_id))
    alert = I18n.t('dul_hydra.permissions.alerts.inherited') % apo_link
    alert.html_safe
  end

  def fixity_checkable?
    current_object.respond_to? :fixity_checks
  end

  def virus_checkable?
    current_object.respond_to? :virus_checks
  end

  def desc_metadata_form_fields
    if current_object.new_record?
      current_object.desc_metadata_terms :required
    else
      current_object.desc_metadata_terms :present, :required
    end
  end

  def desc_metadata_form_field_id field, counter
    "descMetadata__#{field}__#{counter}"
  end

  def desc_metadata_form_field_label field, counter=nil
    label_tag field, nil, for: counter ? desc_metadata_form_field_id(field, counter) : nil
  end

  def desc_metadata_form_field_tag field, value=nil, counter=nil
    name = "descMetadata[#{field}][]"
    opts = { 
      :class => "form-control field-value-input",
      :id => counter ? desc_metadata_form_field_id(field, counter) : nil
    }
    if field == :description
      text_area_tag name, value, opts
    else
      text_field_tag name, value, opts
    end
  end

  def desc_metadata_form_field_values field
    values = current_object.desc_metadata_values field
    values.empty? ? values << "" : values
  end

  def desc_metadata_field_lists
    if current_object.respond_to? :desc_metadata_vocabs
      render partial: 'desc_metadata_form/field_lists', locals: {vocabs: current_object.desc_metadata_vocabs}
    else
      render partial: 'desc_metadata_form/field_list', locals: {label: "Terms", terms: current_object.desc_metadata_terms}
    end
  end

  private

  def render_label(text, label)
    content_tag :span, text, :class => "label label-#{label}"
  end

  def default_thumbnail(doc_or_obj)
    if doc_or_obj.has_content?
      default_mime_type_thumbnail(doc_or_obj.content_type)
    else
      default_model_thumbnail(doc_or_obj.active_fedora_model)
    end
  end
  
  def default_mime_type_thumbnail(mime_type)
    case mime_type
    when /^image/
      'crystal-clear/image2.png'
    when /^video/
      'crystal-clear/video.png'
    when /^audio/
      'crystal-clear/sound.png'
    when /^application\/(x-)?pdf/
      'crystal-clear/document.png'
    when /^application/
      'crystal-clear/binary.png'
    else
      'crystal-clear/misc.png'
    end
  end

  def default_model_thumbnail(model)
    case model
    when 'Collection'
      'crystal-clear/kmultiple.png'
    else
      'crystal-clear/misc.png'
    end
  end

end
