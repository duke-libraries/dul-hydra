class PreservationEventsController < ApplicationController
  
  def show
    @preservation_event = PreservationEvent.find(params[:id])
    authorize! :read, @preservation_event
    respond_to do |format|
      format.html
      format.xml
    end
  end

end
