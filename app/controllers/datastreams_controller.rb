require 'mime/types'

class DatastreamsController < ApplicationController
  
  INLINE_MEDIA_TYPES = ['text', 'image']

  def show
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @datastream = @object.datastreams[params[:id]]
    if params[:download]  
      mimetype = MIME::Types[@datastream.mimeType].first
      disposition = INLINE_MEDIA_TYPES.include?(mimetype.media_type) ? 'inline' : 'attachment'
      send_data @datastream.content, :disposition => disposition, :type => @datastream.mimeType, :filename => "#{@datastream.dsid}.#{mimetype.extensions.first}"    
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
