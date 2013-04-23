class BatchFixityCheckMailer < ActionMailer::Base
  
  default from: "noreply@lib.duke.edu"
  
  def send_report(bfc, mailto)
    @bfc = bfc
    t = @bfc.summary[:at].strftime('%F')
    node = `uname -a`
    @subject = "[#{node}] Batch fixity check report for #{t}"
    attachments['batch_fixity_check_#{t}.csv'] = File.read(@bfc.report.path)
    mail(from: "hydra@#{node}", to: mailto, subject: @subject)
  end

end
