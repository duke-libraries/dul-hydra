class ExportFilesMailer < ActionMailer::Base

  def notify_user(export, user)
    @export = export
    subject = "DDR File Export Complete (#{@export.basename})"
    mail(to: user.email, subject: subject)
  end

end
