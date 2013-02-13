require 'mime/types'

module DulHydra::Controllers
  module DatastreamControllerBehavior
        
    def datastreams
      @title = "#{@object.class.to_s} #{@object.pid} Datastreams"
    end

    def datastream
      @datastream = @object.datastreams[params[:dsid]]
      @title = "#{@object.class.to_s} #{@object.pid} Datastream #{@datastream.dsid}"
    end

    def datastream_content
      ds = @object.datastreams[params[:dsid]]
      mimetype = MIME::Types[ds.mimeType].first
      disposition = mimetype.media_type == 'text' ? 'inline' : 'attachment'
      send_data ds.content, :disposition => disposition, :type => ds.mimeType, :filename => "#{ds.dsid}.#{mimetype.extensions.first}"
    end
    
  end
end
