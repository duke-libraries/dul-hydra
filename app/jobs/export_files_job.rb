class ExportFilesJob < ApplicationJob

  self.queue = :export

  def self.perform(identifiers, basename, user_id)
    export = ExportFiles::Package.call(identifiers, basename: basename)
    if user_id
      user = User.find(user_id)
      ExportFilesMailer.notify_success(export, user).deliver_now
    end
  end

  def self.on_failure(e, identifiers, basename, user_id)
    if user_id
      user = User.find(user_id)
      ExportFilesMailer.notify_failure(identifiers, basename, user).deliver_now
    end
  end

end
