class ExportFilesJob < ActiveJob::Base

  queue_as :export

  def perform(identifiers, basename: nil, user: nil)
    export = ExportFiles::Package.call(identifiers, basename: basename)
    if user
      ExportFilesMailer.notify_user(export, user).deliver_now
    end
  end

end
