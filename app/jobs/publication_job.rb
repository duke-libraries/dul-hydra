class PublicationJob

  def self.send_notification(email:, subject: 'Publication Job', message:)
    mail = JobMailer.basic(to: email,
                           subject: subject,
                           message: message)
    mail.deliver_now
  end

  def self.publication_scope(object)
    I18n.t("dul_hydra.publication.scope.#{object.class.to_s.downcase}")
  end
end
