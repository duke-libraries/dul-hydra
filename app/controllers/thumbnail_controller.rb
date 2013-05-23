class ThumbnailController < ApplicationController

  def show
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    # skip authz
    if @object.has_thumbnail?
      send_data @object.thumbnail.content, :type => @object.thumbnail.mimeType
    else
      render :text => 'Not Found', :status => 404
    end
  end

end
