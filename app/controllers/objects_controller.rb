class ObjectsController < ApplicationController

  include DulHydra::Controller::ObjectsControllerBehavior
  include RecordsControllerBehavior # hydra-editor plugin for descriptive metadata editing

  copy_blacklight_config_from(CatalogController)

  before_filter :enforce_show_permissions, only: [:show, :preservation_events, :collection_info]
  before_filter :configure_blacklight_for_related_objects, only: :show

  helper_method :get_solr_response_for_field_values
  helper_method :object_children
  helper_method :object_attachments
  helper_method :object_preservation_events
  helper_method :new_object
  helper_method :new_model
  helper_method :terms_for_creating

  layout 'application', only: [:new]

  def new
    authorize! :new, new_model
  rescue NameError # This shouldn't happen b/c of route constraint, but what the hell
    CanCan::AccessDenied    
  end

  def create
    authorize! :create, new_model
    new_object.attributes = new_object_attributes
    new_object.permissions = new_object_permissions
    if new_object.save
      redirect_to redirect_after_create, notice: "New #{new_model} successfully created."
    else
      render 'new'
    end
  rescue NameError # This is just a sanity guard against brute force
    CanCan::AccessDenied
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
    methods = case current_object.model_name
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

  def new_object
    @new_object ||= @new_model.new
  end

  def new_model
    @new_model ||= params[:model].camelize.constantize
  end

  def terms_for_creating
    if new_object.respond_to?(:terms_for_creating)
      new_object.terms_for_creating
    else
      DulHydra.terms_for_creating
    end
  end

  def new_object_attributes
    params[new_model.model_name.singluar]
  end

  def new_object_permissions
    if new_object.respond_to?(:initial_permissions)
      new_object.initial_permissions
    else
      # grant edit to current user -- i.e., the object creator
      [Hydra::AccessControls::Permission.new(type: "user", access: "edit", name: current_user.user_key)]
    end
  end

  def redirect_after_create
    case new_model.model_name
    when "AdminPolicy"
      default_permissions_edit_path(new_object)
    else
      object_path(new_object)
    end
  end

  def object_preservation_events
    @object_preservation_events ||= PreservationEvent.events_for(params[:id])
  end

  SolrResult = Struct.new(:response, :documents)

  def object_children
    return @object_children if @object_children
    if current_object.has_children?
      @object_children = SolrResult.new(*get_search_results(params, {q: current_object.children_query}))
      # For compatibility with Blacklight partials and helpers that paginate results
      @response = @object_children.response
      @documents = @object_children.documents
      @partial_path_templates = ["catalog/index_default"]
    end
    @object_children
  end

  def object_attachments
    return @object_attachments if @object_attachments
    if current_object.has_attachments?
      @object_attachments = SolrResult.new(*get_search_results(params, {q: current_object.attachments.send(:construct_query)}))
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

  # Override RecordsControllerBehavior
  def redirect_after_update
    record_path(current_object)
  end

  # tabs
  
  def tab_children(id)
    Tab.new(id, guard: object_children && object_children.response.total > 0)
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
    Tab.new("attachments", guard: object_attachments && object_attachments.response.total > 0)
  end

  def tab_collection_info
    Tab.new("collection_info", 
            href: collection_info_object_path(current_object)
            )
  end

end
