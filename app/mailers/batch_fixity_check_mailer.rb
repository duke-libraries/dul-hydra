class BatchFixityCheckMailer < ActionMailer::Base

  default :from => "noreply@duke.edu"
  
  def send_notification(bfc, mailto)
    @bfc = bfc
    @title = "Batch Fixity Check Results"
    @host = `uname -n`.strip
    @subject = "[#{@host}] #{@title}"
    from = "#{`echo $USER`.strip}@#{@host}"
    if @bfc.report?
      attachments[File.basename(@bfc.report.path)] = File.read(@bfc.report.path)
      @attachment_note = "See attached file for detailed outcome information."
    end
    mail(from: from, to: mailto, subject: @subject)
  end

end
