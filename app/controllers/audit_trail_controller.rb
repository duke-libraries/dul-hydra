class AuditTrailController < ApplicationController
  
  def index
    @object = ActiveFedora::Base.find(params[:object_id], :cast => true)
    authorize! :read, @object
    if params[:download]
      send_data @object.audit_trail.to_xml, :disposition => 'inline', :type => 'text/xml'
    end
  end
  
end