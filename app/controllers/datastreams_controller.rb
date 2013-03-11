# require 'mime/types'

class DatastreamsController < ApplicationController
  
  INLINE_MIME_TYPES = ['application/rdf+xml', 'application/xml', 'text/xml']

  def show
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @datastream = @object.datastreams[params[:id]]
    @display_inline = INLINE_MIME_TYPES.include?(@datastream.mimeType)
    if params[:download]  
      mimetype = MIME::Types[@datastream.mimeType].first
      send_data @datastream.content, :disposition => 'attachment', :type => @datastream.mimeType, :filename => "#{@datastream.dsid}.#{mimetype.extensions.first}"    
    end     
  end

  def thumbnail
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    # skip authz
    if @object.is_a?(DulHydra::Models::HasThumbnail) && @object.has_thumbnail?
      send_data @object.thumbnail.content, :type => @object.thumbnail.mimeType
    else
      render :text => '404 Not Found', :status => 404
    end
  end

end
