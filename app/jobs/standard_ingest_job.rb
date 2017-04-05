class StandardIngestJob
  extend AbstractJob

  @queue = :standard_ingest

  def self.perform(args)
    standard_ingest = StandardIngest.new(args)
    results = standard_ingest.process
    batch_id = results.batch.id if results.batch
    file_count = results.inspection_results.file_count if results.inspection_results
    model_stats = results.inspection_results.content_model_stats if results.inspection_results
    ActiveSupport::Notifications.instrument(StandardIngest::FINISHED,
                                            user_key: args['batch_user'],
                                            folder_path: args['folder_path'],
                                            collection_id: args['collection_id'],
                                            file_count: file_count,
                                            model_stats: model_stats,
                                            errors: results.errors,
                                            batch_id: batch_id)
  end

  def self.on_failure_send_email(e, args)
    send_email(email: User.find_by_user_key(args['batch_user']).email,
               subject: "FAILED - Standard Ingest Job - #{args['folder_path']}",
               message: "Standard Ingest processing for folder #{args['folder_path']} FAILED.")
  end

end
