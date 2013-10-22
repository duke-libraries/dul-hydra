class ObjectsController < ApplicationController

  include Blacklight::Base
  include RecordsControllerBehavior

  copy_blacklight_config_from(CatalogController)

  before_filter :enforce_show_permissions #, only: [:show, :edit, :update, :attachments, :collection_info]
  before_filter :load_document, only: [:show, :edit]
  skip_before_filter :load_and_authorize_record, only: [:edit, :update]
  before_filter :load_record, only: [:edit, :update]
  before_filter :load_object, only: [:show, :edit, :attachments, :collection_info]

  helper_method :get_solr_response_for_field_values
  helper_method :current_object
  helper_method :current_document

  def show
    configure_blacklight_for_related_objects
    load_children
    load_attachments
    configure_tabs :children, :metadata, :default_permissions, :permissions, :preservation_events, :attachments, :collection_info
  end

  # Intended for tab content loaded via ajax
  def preservation_events
    load_preservation_events
    render layout: false
  end

  # Intended for tab content loaded via ajax
  def attachments
    load_attachments
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

  def current_object
    # Include @record for hydra-editor integration
    @object || @record
  end

  def current_document
    @document
  end

  def load_document
    @document = get_solr_response_for_doc_id[1]
  end
  
  def load_object
    if @record # hydra-editor
      # XXX We shouldn't need to do this if https://github.com/duke-libraries/dul-hydra/issues/322 gets done right.
      @object = @record
    elsif @document
      @object = ActiveFedora::SolrService.reify_solr_result(@document)
    else
      @object = ActiveFedora::Base.find(params[:id], cast: true)
    end
  end

  def load_preservation_events
    @preservation_events = PreservationEvent.events_for(params[:id])
  end

  SolrResult = Struct.new(:response, :documents)

  def load_children
    if @object.has_children?
      @children = SolrResult.new(*get_search_results(params, {q: @object.children_query}))
      # For compatibility with Blacklight partials and helpers that paginate results
      @response = @children.response
      @documents = @children.documents
      @partial_path_templates = ["catalog/index_default"]
    end
  end

  def load_attachments
    if @object.has_attachments?
      @attachments = SolrResult.new(*get_search_results(params, {q: @object.attachments.send(:construct_query)}))
      # For compatibility with Blacklight partials and helpers
      @partial_path_templates = ["catalog/index_default"]
    end
  end

  def configure_breadcrumbs(document = @document)
    @breadcrumbs ||= []
    @breadcrumbs << document
    if document.has_parent?
      configure_breadcrumbs(get_solr_response_for_doc_id(document.parent_pid)[1])
    end
  end

  def collection_report
    components = get_collection_components
    total_file_size = 0
    components.documents.each { |doc| total_file_size += (doc.content_size || 0) }
    @report = {
      components: components.response.total,
      items: get_search_results(params, {q: @object.children_query})[0].total,
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
    SolrResult.new(*get_search_results(params, @object.components_query))
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
  def redirect_after_create
    object_path(current_object)
  end

  # Override RecordsControllerBehavior
  def redirect_after_update
    object_path(current_object)
  end

  # tabs

  def tab_content
    Tab.new("Content", "content") if @object.has_content?
  end

  def tab_children
    if @children && @children.response.total > 0
      children_label = @object.class.reflect_on_association(:children).class_name.pluralize
      Tab.new(children_label, "children")
    end
  end

  def tab_metadata
    if @object.respond_to?(:descriptive_metadata_terms)
      Tab.new("Descriptive Metadata", "descriptive_metadata") 
    end
  end

  def tab_default_permissions
    if @object.respond_to?(:default_permissions)
      Tab.new("Default Permissions", "default_permissions")
    end
  end

  def tab_permissions
    Tab.new("Permissions", "permissions")
  end

  def tab_preservation_events
    if @object.has_preservation_events?
      Tab.new("Preservation Events", "preservation_events", preservation_events_object_path(@object))
    end
  end

  def tab_attachments
    if @attachments && @attachments.response.total > 0
      Tab.new("Attachments", "attachments")
    end
  end

  def tab_collection_info
    if @object.is_a?(Collection)
      Tab.new("Collection Info", "collection_info", collection_info_object_path(@object))
    end
  end

end
