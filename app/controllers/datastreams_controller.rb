# require 'mime/types'

class DatastreamsController < ApplicationController

  TEXT_TYPES = /^(text\/.+|application\/((rdf\+)?xml|json))$/
  IMAGE_TYPES = /^image\/(jpeg|png)$/
  
  def show
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @datastream = @object.datastreams[params[:id]]
    if TEXT_TYPES =~ @datastream.mimeType
      @type = :text
    elsif IMAGE_TYPES =~ @datastream.mimeType
      @type = :image
    else
      @type = :other
    end
  end

  def image_content
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @datastream = @object.datastreams[params[:id]]    
    if @datastream.mimeType.start_with?('image/')
      send_data @datastream.content, :type => @datastream.mimeType
    else
      render :text => 'Not Found', :status => 404
    end
  end

  def download
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @datastream = @object.datastreams[params[:id]]
    mimetype = MIME::Types[@datastream.mimeType].first
    send_data @datastream.content, :disposition => 'attachment', :type => @datastream.mimeType, :filename => "#{@datastream.dsid}.#{mimetype.extensions.first}"        
  end

  def thumbnail
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    # skip authz
    if @object.is_a?(DulHydra::Models::HasThumbnail) && @object.has_thumbnail?
      send_data @object.thumbnail.content, :type => @object.thumbnail.mimeType
    else
      render :text => 'Not Found', :status => 404
    end
  end

end
