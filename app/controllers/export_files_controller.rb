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
        ExportFilesJob.perform_later(@export.identifiers,
                                     basename: @export.basename,
                                     user: current_user)
      end
    else # not valid
      flash.now[:error] = "Export request cannot be processed: " +
                          @export.errors.full_messages.join("; ")
      render :new
    end
  end

end
