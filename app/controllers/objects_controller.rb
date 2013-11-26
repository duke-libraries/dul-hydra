class ObjectsController < ApplicationController

  include DulHydra::Controller::ObjectsControllerBehavior
  include RecordsControllerBehavior # hydra-editor plugin for descriptive metadata editing

  copy_blacklight_config_from(CatalogController)

  before_filter :enforce_show_permissions, only: [:show, :preservation_events, :collection_info]
  before_filter :configure_blacklight_for_related_objects, only: :show
  before_filter :load_and_authorize_new_object, only: [:new, :create]

  helper_method :get_solr_response_for_field_values
  helper_method :object_children
  helper_method :object_attachments
  helper_method :object_preservation_events

  layout 'application', only: [:new, :create]

  def new
    # Overriding RecordsControllerBehavior
  end

  def create
    @object.attributes = params[:object].reject {|key, value| value.blank?}
    set_initial_permissions
    if @object.save
      redirect_to redirect_after_create, notice: "New #{@model} successfully created."
    else
      render :action => 'new'
    end
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

  def set_initial_permissions
    if @object.respond_to?(:set_initial_permissions)
      @object.set_initial_permissions(current_user)
    end
  end

  def load_and_authorize_new_object
    @model = params[:model].camelize.constantize
    authorize! :create, @model
    @object = @model.new
  rescue NameError # This shouldn't happen, but what the hell
    raise CanCan::AccessDenied    
  end

  def redirect_after_create
    case @object.class.to_s
    when "AdminPolicy"
      default_permissions_path(@object)
    else
      object_path(@object)
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
