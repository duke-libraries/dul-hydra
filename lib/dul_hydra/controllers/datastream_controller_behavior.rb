require 'mime/types'

module DulHydra::Controllers
  module DatastreamControllerBehavior
        
    def datastreams
      @obj = model_instance_variable_get
      @dsid = params[:dsid]
    end

    def datastream
      @obj = model_instance_variable_get
      @datastream = @obj.datastreams[params[:dsid]]
      @title = "#{@obj.class.to_s} #{@obj.pid} Datastream #{@dsid}"
    end

    def datastream_content
      obj = model_instance_variable_get
      ds = obj.datastreams[params[:dsid]]
      mimetype = MIME::Types[ds.mimeType].first
      disposition = mimetype.media_type == 'text' ? 'inline' : 'attachment'
      send_data ds.content, :disposition => disposition, :type => ds.mimeType, :filename => "#{ds.dsid}.#{mimetype.extensions.first}"
    end
    
  end
end
