class StandardIngestJob
  extend AbstractJob

  @queue = :standard_ingest

  def self.perform(args)
    standard_ingest = StandardIngest.new(args)
    standard_ingest.process
    send_email(email: User.find_by_user_key(args['batch_user']).email,
               subject: "COMPLETED - Standard Ingest Job - #{args['folder_path']}",
               message: "Standard Ingest processing for folder #{args['folder_path']} has completed.")
  end

  def self.on_failure_send_email(e, args)
    send_email(email: User.find_by_user_key(args['batch_user']).email,
               subject: "FAILED - Standard Ingest Job - #{args['folder_path']}",
               message: "Standard Ingest processing for folder #{args['folder_path']} FAILED.")
  end

end
