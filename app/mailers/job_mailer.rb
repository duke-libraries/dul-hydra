class JobMailer < ActionMailer::Base

  def basic(subject: "Job", to:, message: nil)
    body = message || "The job you enqueued has completed."
    mail(from: from_address, to: to, subject: subject, body: message)
  end

  private

  def from_address
    Rails.application.config.action_mailer.default_options[:from]
  rescue
    'job-queue@test.edu'
  end

end
