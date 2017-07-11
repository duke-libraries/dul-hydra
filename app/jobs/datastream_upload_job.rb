class DatastreamUploadJob
  extend AbstractJob

  @queue = :datastream_upload

  def self.perform(args)
    datastream_upload = DatastreamUpload.new(args)
    results = datastream_upload.process
    batch_id = results.batch.id if results.batch
    file_count = results.inspection_results.filesystem.file_count if results.inspection_results
    ActiveSupport::Notifications.instrument(DatastreamUpload::FINISHED,
                                            user_key: args['batch_user'],
                                            basepath: args['basepath'],
                                            subpath: args['subpath'],
                                            collection_id: args['collection_id'],
                                            file_count: file_count,
                                            errors: results.errors,
                                            batch_id: batch_id)
  end

  def self.on_failure_send_email(e, args)
    folder_path = File.join(args['basepath'], args['subpath'])
    send_email(email: User.find_by_user_key(args['batch_user']).email,
               subject: "FAILED - Datastream Upload Job - #{folder_path}",
               message: "Datastream Upload processing for folder #{folder_path} FAILED.")
  end

end
