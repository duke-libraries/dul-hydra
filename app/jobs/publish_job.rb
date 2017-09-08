class PublishJob < PublicationJob

  @queue = :publication

  def self.perform(id, email_addr)
    obj = ActiveFedora::Base.find(id)
    obj.publish!
    send_notification(email: email_addr,
                      subject: 'Publication Job COMPLETED',
                      message: "Publication of #{id} (and its descendants) has completed.")
  end

  def self.on_failure_send_notification(exception, id, email_addr)
    send_notification(email: email_addr,
                      subject: 'Publication Job FAILED',
                      message: "Publication of #{id} (and its descendants) FAILED.")
  end

end
