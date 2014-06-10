class EventsController < ApplicationController

  load_and_authorize_resource only: :show

  def index
    @pid = params[:pid].present? && params[:pid]
    respond_to do |format|
      format.html do
        @events = Event.accessible_by(current_ability)
        @events = @events.for_pid(@pid) if @pid
        if request.xhr?
          render layout: false
        end
      end
      format.xml do
        @events = PreservationEvent.accessible_by(current_ability)
        if params[:pid].present?
          @events = @events.for_pid(params[:pid])
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml
    end
  end

end
