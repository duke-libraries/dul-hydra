class BatchProcessorRunMailer < ActionMailer::Base

  default :from => "noreply@duke.edu"
  
  def send_notification(batch_run, mailto)
    @batch_run = batch_run
    @title = "Batch Processor Run Results"
    @host = `uname -n`.strip
    @subject = "[#{@host}] #{@title}"
    from = "#{`echo $USER`.strip}@#{@host}"
    attachments["details.txt"] = @batch_run.details
    mail(from: from, to: mailto, subject: @subject)
  end

end
