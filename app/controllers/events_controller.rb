class EventsController < ApplicationController

  load_and_authorize_resource only: :show

  def index
    @events = []
    @pid = params[:pid].present? && params[:pid]
    events = @pid.present? ? Event.for_pid(@pid) : Event.all
    events.each do |event|
      @events << event if can? :read, event
    end
    respond_to do |format|
      format.html do
        if request.xhr?
          render layout: false
        end
      end
      format.xml
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml
    end
  end

end
