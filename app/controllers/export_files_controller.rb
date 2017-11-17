class ExportFilesController < ApplicationController

  rescue_from ActionController::ParameterMissing do |e|
    flash.now[:error] = e.message
    render :new
  end

  def create
    identifiers = params.require(:identifiers).strip.split
    @export = ExportFiles::Package.new(identifiers,
                                       ability: current_ability,
                                       basename: params.require(:basename))
    if @export.valid?
      @confirmed = params[:confirmed]
      if @confirmed
        Resque.enqueue(ExportFilesJob,
                       @export.identifiers,
                       @export.basename,
                       current_user)
      end
    else # not valid
      flash.now[:error] = "Export request cannot be processed: " +
                          @export.errors.full_messages.join("; ")
      render :new
    end
  end

end
