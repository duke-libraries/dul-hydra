class ReportMailer < ActionMailer::Base

  def basic(subject: "Report", to:, filename: "report.csv", content:, message: nil)
    body = message || "The report you requested is attached."
    attachments[filename] = content
    mail(to: to, subject: subject, body: body)
  end

end
