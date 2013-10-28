class BatchProcessorRunMailer < ActionMailer::Base

  default :from => "noreply@duke.edu"
  
  def send_notification(batch)
    @batch = batch
    @title = "Batch Processor Run Results"
    @host = `uname -n`.strip
    @subject = "[#{@host}] #{@title}"
    from = "#{`echo $USER`.strip}@#{@host}"
    attachments["details.txt"] = @batch.details
    mail(from: from, to: @batch.user.email, subject: @subject)
  end

end
