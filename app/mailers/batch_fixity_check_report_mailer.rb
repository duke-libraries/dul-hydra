class BatchFixityCheckReportMailer < ActionMailer::Base
  
  default from: "noreply@lib.duke.edu"
  
  def report_email(batch_fixity_check, toaddrs)
    attachments['report.csv'] = File.read(batch_fixity_check.report.path)
    mail(to: toaddrs, subject: "Batch fixity check report")
  end

end
