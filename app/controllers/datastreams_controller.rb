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

end
