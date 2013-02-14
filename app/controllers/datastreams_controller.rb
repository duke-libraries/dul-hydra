require 'mime/types'

class DatastreamsController < ApplicationController

  def index
    # XXX load from solr?
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @title = "#{@object.pid} Datastreams"
  end

  def show
    # XXX load from solr?
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    @datastream = @object.datastreams[params[:id]]
    @title = "#{@object.pid} Datastream #{params[:id]}"
  end

  def content    
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    ds = @object.datastreams[params[:id]]
    mimetype = MIME::Types[ds.mimeType].first
    disposition = mimetype.media_type == 'text' ? 'inline' : 'attachment'
    send_data ds.content, :disposition => disposition, :type => ds.mimeType, :filename => "#{ds.dsid}.#{mimetype.extensions.first}"
  end

end
