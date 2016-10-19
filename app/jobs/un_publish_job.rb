class UnPublishJob < PublicationJob

  @queue = :publication

  def self.perform(id, email_addr)
    obj = ActiveFedora::Base.find(id)
    obj.unpublish!
    send_notification(email: email_addr,
                      subject: 'Un-Publication Job COMPLETED',
                      message: "Un-Publication of #{id} (and its descendants) has completed.")
  end

  def self.on_failure_send_notification(id, email_addr)
    send_notification(email: email_addr,
                      subject: 'Un-Publication Job FAILED',
                      message: "Un-Publication of #{id} (and its descendants) FAILED.")
  end

end
