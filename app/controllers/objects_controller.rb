class ObjectsController < ApplicationController

  include DulHydra::Controller::ObjectsControllerBehavior
  include RecordsControllerBehavior # hydra-editor plugin for descriptive metadata editing

  copy_blacklight_config_from(CatalogController)

  SHOW_VIEWS = [:show, :preservation_events, :collection_info]

  before_filter :enforce_show_permissions, only: SHOW_VIEWS

  before_filter :configure_blacklight_for_related_objects, only: :show

  helper_method :get_solr_response_for_field_values
  helper_method :object_children
  helper_method :object_attachments
  helper_method :object_preservation_events

  ObjectsController.tab_methods = [:tab_children, 
                                   :tab_descriptive_metadata, 
                                   :tab_default_permissions, 
                                   :tab_permissions, 
                                   :tab_preservation_events, 
                                   :tab_attachments, 
                                   :tab_collection_info
                                  ]

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

  protected

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
  
  def tab_content
    Tab.new("Content", "content") if current_object.has_content?
  end

  def tab_children
    if object_children && object_children.response.total > 0
      children_label = current_object.class.reflect_on_association(:children).class_name.pluralize
      Tab.new(children_label, "children")
    end
  end

  def tab_descriptive_metadata
    if current_object.respond_to?(:descriptive_metadata_terms)
      Tab.new("Descriptive Metadata", "descriptive_metadata") 
    end
  end

  def tab_default_permissions
    if current_object.respond_to?(:default_permissions)
      Tab.new("Default Permissions", "default_permissions")
    end
  end

  def tab_permissions
    Tab.new("Permissions", "permissions")
  end

  def tab_preservation_events
    if current_object.has_preservation_events?
      Tab.new("Preservation Events", "preservation_events", preservation_events_object_path(current_object))
    end
  end

  def tab_attachments
    if object_attachments && object_attachments.response.total > 0
      Tab.new("Attachments", "attachments")
    end
  end

  def tab_collection_info
    if current_object.is_a?(Collection)
      Tab.new("Collection Info", "collection_info", collection_info_object_path(current_object))
    end
  end

end
