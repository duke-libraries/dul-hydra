require 'mime/types'

module DulHydra::Catalog

  def model_index
    @title = params[:model].pluralize
    @solr_response, @document_list = get_solr_response_for_field_values(:active_fedora_model_s, params[:model])
  end

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
