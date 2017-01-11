class SimpleIngestJob
  extend AbstractJob

  @queue = :simple_ingest

  def self.perform(args)
    simple_ingest = SimpleIngest.new(args)
    simple_ingest.process
    send_email(email: User.find_by_user_key(args['batch_user']).email,
               subject: "COMPLETED - Simple Ingest Job - #{args['folder_path']}",
               message: "Simple Ingest processing for folder #{args['folder_path']} has completed.")
  end

  def self.on_failure_send_email(e, args)
    send_email(email: User.find_by_user_key(args['batch_user']).email,
               subject: "FAILED - Simple Ingest Job - #{args['folder_path']}",
               message: "Simple Ingest processing for folder #{args['folder_path']} FAILED.")
  end

end
