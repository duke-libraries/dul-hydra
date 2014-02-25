class ObjectsController < ApplicationController

  include DulHydra::ObjectsControllerBehavior
  include RecordsControllerBehavior 

  copy_blacklight_config_from(CatalogController)

  before_action :enforce_show_permissions, only: [:show, :preservation_events, :collection_info]
  before_action :configure_blacklight_for_related_objects, only: :show

  before_action :set_extra_params, only: [:new, :create]
  before_action :set_initial_permissions, only: :create
  after_action :creation_event, only: :create
  after_action :log_event, only: [:create, :update]

  helper_method :object_children
  helper_method :object_attachments
  helper_method :object_preservation_events

  helper_method :resource_instance_name # RecordsControllerBehavior method

  layout 'application', only: [:new, :create]

  #
  # #new, #create, #edit, and #update actions acquired from RecordsControllerBehavior
  #

  def new
    initialize_fields
  end

  def show
    object_children # lazy loading doesn't seem to work
  end

  # Intended for tab content loaded via ajax
  def preservation_events
    render layout: false
  end
  
  # HTML format intended for tab content loaded via ajax
  def collection_info
    respond_to do |format|
      format.html do 
        collection_report
        render layout: false
      end
      format.csv { send_data(collection_csv_report, type: "text/csv") }
    end
  end

  def tabs
    methods = case current_object.class.to_s
              when "AdminPolicy"
                [:tab_descriptive_metadata, 
                 :tab_default_permissions, 
                 :tab_permissions]
              when "Collection"
                [:tab_items,
                 :tab_descriptive_metadata, 
                 :tab_permissions, 
                 :tab_preservation_events, 
                 :tab_attachments, 
                 :tab_collection_info]
              when "Item"
                [:tab_components, 
                 :tab_descriptive_metadata, 
                 :tab_permissions, 
                 :tab_preservation_events, 
                 :tab_attachments]
              when "Component"
                [:tab_descriptive_metadata, 
                 :tab_permissions, 
                 :tab_preservation_events, 
                 :tab_attachments]      
              when "Attachment", "Target"
                [:tab_descriptive_metadata, 
                 :tab_permissions, 
                 :tab_preservation_events]
              end
    Tabs.new(self, *methods)
  end

  protected

  #
  # Filters
  #
  def set_initial_permissions
    resource.set_initial_permissions(current_user) if resource.respond_to?(:set_initial_permissions)
  end
  
  def set_extra_params
    set_admin_policy
    set_attached_to
    set_content
  end

  def set_attached_to
    if params[:attached_to_id].present?
      attached_to = ActiveFedora::Base.find(params[:attached_to_id], cast: true)
      authorize! :add_attachment, attached_to
      resource.attached_to = attached_to
    end
  rescue ActiveFedora::ObjectNotFoundError
    resource.errors.add(:attached_to_id, "Object to attach to having PID #{params[:attached_to_id]} was not found.")
  end

  def set_admin_policy
    if params[:admin_policy_id].present?
      admin_policy = AdminPolicy.find(params[:admin_policy_id])
      resource.admin_policy = admin_policy
    end
  rescue ActiveFedora::ObjectNotFoundError
    resource.errors.add(:admin_policy_id, "AdminPolicy object having PID #{params[:admin_policy_id]} was not found")
  end

  def set_content
    if resource.respond_to?(:set_content) and params[:content].present?
      file = params[:content] 
      if file.respond_to?(:path) # Sanitize user input
        resource.set_content(file)
      end
    end
  end

  def creation_event
    if resource.persisted? and resource.can_have_preservation_events?
      PreservationEvent.creation!(resource, current_user)
    end
  end

  def log_event
    if resource.errors.empty?
      resource.event_log_for_action(user: current_user, action: params[:action], comment: params[:comment])
    end
  end
  
  #
  # Overrides of RecordsControllerBehavior
  #
  def collect_form_attributes
    raw_attributes = params[resource_instance_name]
    # we could probably do this with strong parameters if the gemspec depends on Rails 4+
    permitted_attributes = resource.terms_for_editing.each_with_object({}) { |key, attrs| attrs[key] = raw_attributes[key] if raw_attributes[key] }
    # removes attributes that were only changed by initialize_fields
    permitted_attributes.reject { |key, value| resource[key].empty? and value == [""] }
  end

  def redirect_after_create
    case resource.class.to_s
    when "AdminPolicy"
      default_permissions_path(resource)
    else
      object_path(resource)
    end
  end

  def redirect_after_update
    record_path(resource)
  end

  def object_preservation_events
    @object_preservation_events ||= PreservationEvent.events_for(params[:id])
  end

  SolrResult = Struct.new(:response, :documents)

  def object_children
    return @object_children if @object_children
    if current_object.can_have_children?
      @object_children = SolrResult.new(*get_search_results(params, children_query_params))
      # For compatibility with Blacklight partials and helpers that paginate results
      @response = @object_children.response
      @documents = @object_children.documents
      @partial_path_templates = ["catalog/index_default"]
    end
    @object_children
  end

  def has_children?
    current_object.can_have_children? and query_count(params, children_query_params) > 0
  end

  def children_query_params
    {q: current_object.children_query}
  end

  def has_attachments?
    current_object.can_have_attachments? and query_count(params, attachments_query_params) > 0
  end

  def attachments_query_params
    {q: current_object.attachments.send(:construct_query)}
  end

  def object_attachments
    return @object_attachments if @object_attachments
    if current_object.can_have_attachments?
      @object_attachments = SolrResult.new(*get_search_results(params, attachments_query_params))
      # For compatibility with Blacklight partials and helpers
      @partial_path_templates = ["catalog/index_default"]
    end
    @object_attachments
  end

  def collection_report
    components = get_collection_components
    total_file_size = 0
    components.documents.each { |doc| total_file_size += (doc.content_size || 0) }
    @report = {
      components: components.response.total,
      items: get_search_results(params, {q: current_object.children_query})[0].total,
      total_file_size: total_file_size
    }
  end

  def collection_csv_report
    CSV.generate do |csv|
      csv << DulHydra.collection_report_fields.collect {|f| f.to_s.upcase}
      get_collection_components.documents.each do |doc|
        csv << DulHydra.collection_report_fields.collect {|f| doc.send(f)}
      end
    end
  end

  def get_collection_components
    SolrResult.new(*get_search_results(params, current_object.components_query))
  end

  def configure_blacklight_for_related_objects
    blacklight_config.configure do |config|
      # Clear sort fields
      config.sort_fields.clear
      # Add custom sort fields for this query                                                                        
      config.add_sort_field "#{DulHydra::IndexFields::IDENTIFIER} asc", label: 'Identifier'
      config.add_sort_field "#{DulHydra::IndexFields::TITLE} asc", label: 'Title'
      # XXX Not sure this is necessary
      config.default_sort_field = "#{DulHydra::IndexFields::IDENTIFIER} asc"
      #config.qt = "standard"
    end
  end

  #
  # Tabs
  #
  def tab_children(id)
    Tab.new(id, guard: has_children?)
  end

  def tab_items
    tab_children("items")
  end

  def tab_components
    tab_children("components")
  end

  def tab_descriptive_metadata
    Tab.new("descriptive_metadata",
            actions: [
                      TabAction.new("edit",
                                    record_edit_path(current_object),
                                    can?(:edit, current_object)),
                      TabAction.new("download",
                                    download_datastream_object_path(current_object, "descMetadata"),
                                    can?(:download, current_object.descMetadata))
                      ]
            )
  end

  def tab_default_permissions
    Tab.new("default_permissions",
            actions: [
                      TabAction.new("edit", 
                                    default_permissions_edit_path(current_object),
                                    can?(:edit, current_object)),
                      TabAction.new("download",
                                    download_datastream_object_path(current_object, "defaultRights"),
                                    can?(:download, current_object.defaultRights))
                     ]
            )
  end

  def tab_permissions
    Tab.new("permissions",
            actions: [
                      TabAction.new("edit", 
                                    permissions_edit_path(current_object),
                                    can?(:edit, current_object)),
                      TabAction.new("download",
                                    download_datastream_object_path(current_object, "rightsMetadata"),
                                    can?(:download, current_object.rightsMetadata))
                     ]
            )
  end

  def tab_preservation_events
    Tab.new("preservation_events", 
            href: preservation_events_object_path(current_object),
            guard: current_object.has_preservation_events?)
  end

  def tab_attachments
    Tab.new("attachments", guard: has_attachments?)
  end

  def tab_collection_info
    Tab.new("collection_info", 
            href: collection_info_object_path(current_object)
            )
  end

end
