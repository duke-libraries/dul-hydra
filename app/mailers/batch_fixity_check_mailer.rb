class BatchFixityCheckMailer < ActionMailer::Base

  default from: "no-reply@duke.edu" unless default[:from]
  default reply_to: "no-reply@duke.edu"

  def send_notification(bfc, mailto)
    @subject = "Batch Fixity Check Results"
    @host = default_url_options[:host]
    @bfc = bfc
    if @bfc.report?
      attachments[File.basename(@bfc.report.path)] = File.read(@bfc.report.path)
      @attachment_note = "See attached file for detailed outcome information."
    end
    mail(to: mailto, subject: @subject)
  end

end
