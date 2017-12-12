class ExportFilesMailer < ActionMailer::Base

  def notify_success(export, user)
    @export = export
    subject = "DDR File Export COMPLETED (#{@export.basename})"
    mail(to: user.email, subject: subject)
  end

  def notify_failure(identifiers, basename, user)
    @identifiers = identifiers
    @basename = basename
    subject = "DDR File Export FAILED (#{@basename})"
    mail(to: user.email, subject: subject)
  end

end
