class BatchFixityCheckMailer < ActionMailer::Base

  default from: "no-reply@duke.edu" unless default[:from]
  default reply_to: "no-reply@duke.edu"

  def send_notification(bfc, mailto)
    @bfc = bfc
    result = @bfc.outcome_counts.include?(Ddr::Events::Event::FAILURE) ? "FAILURE" : "SUCCESS"
    @subject = "DDR Fixity Results: #{result}"
    @host = default_url_options[:host]
    if @bfc.report? && @bfc.total > 0
      attachments[File.basename(@bfc.report.path)] = File.read(@bfc.report.path)
      @attachment_note = "See attached file for detailed outcome information."
    end
    mail(to: mailto, subject: @subject)
  end

end
