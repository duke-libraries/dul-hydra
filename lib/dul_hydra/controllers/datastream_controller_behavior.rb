require 'mime/types'

module DulHydra::Controllers
  module DatastreamControllerBehavior
        
    def datastreams
      # display list of datastreams for an object
    end

    def datastream
      # display profile information for a datastream
    end

    def datastream_content
      ds = model_instance_var.datastreams[params[:dsid]]
      mimetype = MIME::Types[ds.mimeType].first
      disposition = mimetype.media_type == 'text' ? 'inline' : 'attachment'
      send_data ds.content, :disposition => disposition, :type => ds.mimeType, :filename => "#{ds.dsid}.#{mimetype.extensions.first}"
    end
    
  end
end
