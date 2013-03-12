require 'mime/types'

class DatastreamsController < ApplicationController

  TEXT_MIME_TYPES = ['application/xml', 'application/rdf+xml', 'application/json']
  
  def show
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @datastream = @object.datastreams[params[:id]]
    @inline = @datastream.mimeType.start_with?('text/') || TEXT_MIME_TYPES.include?(@datastream.mimeType)
  end

  def download
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @datastream = @object.datastreams[params[:id]]
    mimetypes = MIME::Types[@datastream.mimeType]
    # XXX refactor - use utility method to get file name
    send_data @datastream.content, :disposition => 'attachment', :type => @datastream.mimeType, :filename => "#{@datastream.pid.replace(':', '_')}_#{@datastream.dsid}.#{mimetypes.first.extensions.first}"        
  end

end
