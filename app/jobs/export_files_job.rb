class ExportFilesJob < ApplicationJob

  self.queue = :export

  def self.perform(identifiers, basename, user)
    export = ExportFiles::Package.call(identifiers, basename: basename)
    if user
      ExportFilesMailer.notify_success(export, user).deliver_now
    end
  end

  def self.on_failure(e, identifiers, basename, user)
    if user
      ExportFilesMailer.notify_failure(identifiers, basename, user).deliver_now
    end
  end

end
