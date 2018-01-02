class PublishJob < PublicationJob

  @queue = :publication

  def self.perform(id, email_addr)
    obj = ActiveFedora::Base.find(id)
    obj.publish!
    send_notification(email: email_addr,
                      subject: 'Publication Job COMPLETED',
                      message: "Publication of #{id} (#{self.publication_scope(obj)}) has completed.")
  end

  def self.on_failure_send_notification(exception, id, email_addr)
    begin
      obj = ActiveFedora::Base.find(id)
      message = "Publication of #{id} (#{self.publication_scope(obj)}) FAILED."
    rescue ActiveFedora::ObjectNotFoundError
      message = "Object #{id} Not Found"
    end
    send_notification(email: email_addr,
                      subject: 'Publication Job FAILED',
                      message: message)
  end

end
