module ApplicationHelper

  def render_admin_metadata_form_field(form, field)
    render partial: "admin_metadata_form/#{field}", locals: {f: form}
  rescue ActionView::MissingTemplate
    if current_object.class.multiple?(field)
      render partial: "admin_metadata_form/multi_valued", locals: {field: field}
    else
      render partial: "admin_metadata_form/generic", locals: {f: form, field: field}
    end
  end

  def admin_metadata_form_field_label(field)
    I18n.t("dul_hydra.admin_metadata.#{field}", default: field.to_s.titleize)
  end

  def research_help_contact_options_for_select
    options_from_collection_for_select(Ddr::Models::Contact.all, :slug, :name, current_object.research_help_contact)
  end

  def rights_options_for_select(value)
    options_from_collection_for_select(Ddr::Models::RightsStatement.all, :url, :title, value)
  end

  def admin_set_options_for_select
    options_from_collection_for_select(Ddr::Models::AdminSet.all, :code, :title, current_object.admin_set)
  end

  def alert_messages
    Ddr::Alerts::Message.active.pluck(:message)
  end

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
    content_tag :span, nil, class: "glyphicon glyphicon-user"
  end

  def group_icon(group = nil)
    case group
    when Ddr::Auth::Groups::PUBLIC
      public_icon
    else
      image_tag("silk/group.png", size: "16x16", alt: "group")
    end
  end

  def public_icon
    content_tag :span, nil, class: "glyphicon glyphicon-globe"
  end

  def render_object_identifier
    if current_object.identifier.respond_to?(:join)
      current_object.identifier.join("<br />")
    else
      current_object.identifier
    end
  end

  def object_info_item(value: nil, label:, status: nil)
    render partial: "object_info_item", locals: {value: value, label: label, status: status}
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

  def render_content_type_and_size(doc_or_obj)
    "#{doc_or_obj.content_type} #{doc_or_obj.content_size_human}"
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

  def render_stream_link(document, args = {})
    label = args.fetch(:label, "Stream")
    link_to label, url_for(controller: document.controller_name, id: document.id, action: "stream"), class: args[:css_class], target: args[:target]
  end

  def thumbnail_image_tag document, image_options = {}
    src = document.has_thumbnail? ? thumbnail_path(document) : default_thumbnail(document)
    thumbnail = image_tag(src, alt: "Thumbnail", class: "img-thumbnail", size: "100x100")
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
      date = Time.parse(date.to_s) if !date.respond_to?(:localtime)
      date.localtime.to_s
    end
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

  def link_to_object(pid, access = :read)
    doc = SolrDocument.find(pid)
    link_to_if can?(access, doc), pid, document_or_object_url(doc)
  end

  def link_to_create_model(model)
    link_to I18n.t("dul_hydra.#{model.underscore}.new_menu", default: model), send("new_#{model.tableize.singularize}_path")
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

  def all_user_options
    @all_user_options ||= user_options(User.order(:last_name, :first_name))
  end

  def group_options(groups)
    groups.map { |group| group_option(group) }
  end

  def group_option(group)
    [group.label, group.to_s]
  end

  def all_group_options
    # TODO: List public first, then registered, then rest in alpha order (?)
    @all_group_options ||= group_options(Ddr::Auth::Groups.all)
  end

  def user_options(users)
    users.map { |user| user_option(user) }
  end

  def user_option(user)
    option_text = user.display_name ? "#{user.display_name} (#{user})" : user.to_s
    option_value = user.to_s
    [option_text, option_value]
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
    case field
    when :abstract, :description
      text_area_tag(name, value, opts)
    when :rights
      select_tag(name,
                 rights_options_for_select(value),
                 opts.merge(include_blank: "(Select rights statement)")
                )
    else
      text_field_tag(name, value, opts)
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

  def original_filename_info
    info = {}
    if current_object.has_content?
      if current_object.original_filename
        info[:value] = current_object.original_filename
        info[:context] = 'info'
      else
        info[:value] = 'Missing'
        info[:context] = 'danger'
      end
    else
      info[:value] = 'No content file'
      info[:context] = 'warning'
    end
    return info
  end

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

  # Overrides corresponding method in Blacklight::FacetsHelperBehavior
  def render_facet_limit_list(paginator, solr_field, wrapping_element=:li)
    case solr_field
      when Ddr::Index::Fields::ADMIN_SET_FACET
        # apply custom sort for 'admin set' facet
        items = admin_set_facet_sort(paginator.items)
      else
        items = paginator.items
    end
    safe_join(items.
        map { |item| render_facet_item(solr_field, item) }.compact.
        map { |item| content_tag(wrapping_element,item) }
    )
  end

  # Facet field view helper
  # Also used in custom sort for admin set facet
  def admin_set_title(code)
    admin_set_titles[code]
  end

  # Custom sort for 'admin set' facet
  # Sort by full name of admin set normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the admin set code
  def admin_set_facet_sort(items=[])
    items.sort { |a,b| admin_set_title(a.value).downcase <=> admin_set_title(b.value).downcase }
  end

  def admin_set_titles
    @admin_set_titles ||= Ddr::Models::AdminSet.all.each_with_object({}) { |a, memo| memo[a.code] = a.title }
  end

  # Display git branch on preview banner
  def git_branch_info
    branch_name = `git rev-parse --abbrev-ref HEAD`
    branch_name
  end

end
