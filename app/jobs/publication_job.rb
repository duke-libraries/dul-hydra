class PublicationJob

  def self.send_notification(email:, subject: 'Publication Job', message:)
    mail = JobMailer.basic(to: email,
                           subject: subject,
                           message: message)
  end

end
