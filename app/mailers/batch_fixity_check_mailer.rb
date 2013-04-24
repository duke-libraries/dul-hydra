class BatchFixityCheckMailer < ActionMailer::Base

  default :from => "noreply@duke.edu"
  
  def send_report(bfc, mailto)
    @bfc = bfc
    @host = `uname -n`.strip
    @subject = "[#{@host}] Batch fixity check report"
    from = "#{`echo $USER`.strip}@#{@host}"
    attachments[File.basename(@bfc.report.path)] = File.read(@bfc.report.path)
    mail(from: from, to: mailto, subject: @subject)
  end

end
