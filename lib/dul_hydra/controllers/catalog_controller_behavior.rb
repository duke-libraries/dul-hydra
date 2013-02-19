module DulHydra::Controllers
  module CatalogControllerBehavior

    include DulHydra::SolrHelper

    def model_index
      self.solr_search_params_logic += [:af_model_filter]
      @title = params[:model].pluralize
      @response, @document_list = get_search_results
    end

    def preservation_events
      self.solr_search_params_logic += [:preservation_events_filter]
      @title = "Preservation Events for #{params[:object_id]}"
      @response, @document_list = get_search_results
    end

    # XXX DEPRECATED
    def datastreams
      # @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
      # authorize! :read, @object
      @object = ActiveFedora::Base.load_instance_from_solr(params[:object_id]) # XXX authz?
      @title = "#{@object.pid} Datastreams"
    end

    def datastream
      @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
      authorize! :read, @object
      # @object = ActiveFedora::Base.load_instance_from_solr(params[:object_id]) # XXX authz?
      @datastream = @object.datastreams[params[:id]]
      @title = "#{@object.pid} Datastream #{params[:id]}"
    end

    def datastream_content    
      @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
      authorize! :read, @object
      ds = @object.datastreams[params[:id]]
      mimetype = MIME::Types[ds.mimeType].first
      disposition = mimetype.media_type == 'text' ? 'inline' : 'attachment'
      send_data ds.content, :disposition => disposition, :type => ds.mimeType, :filename => "#{ds.dsid}.#{mimetype.extensions.first}"
    end

  end
end
