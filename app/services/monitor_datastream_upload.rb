class MonitorDatastreamUpload

  class << self
    def call(*args)
      event = ActiveSupport::Notifications::Event.new(*args)
      user = User.find_by_user_key(event.payload[:user_key])
      folder_path = File.join(event.payload[:basepath], event.payload[:subpath])
      collection_id = event.payload[:collection_id]
      file_count = event.payload[:file_count]
      errors = event.payload[:errors]
      batch = Ddr::Batch::Batch.find(event.payload[:batch_id]) if event.payload[:batch_id]
      coll_title = collection_title(collection_id)
      if errors.present?
        email_errors(user, coll_title, folder_path, errors )
      else
        email_success(user, coll_title, folder_path, file_count, batch)
      end
    end

    private

    def email_success(user, coll_title, folder_path, file_count, batch)
      msg = <<~EOS
        Datastream Upload has created batch ##{batch.id}
        For collection: #{coll_title}
        From folder: #{folder_path}
        Files found: #{file_count}

        To review and process the batch, go to #{batch_url(batch)}
      EOS
      JobMailer.basic(to: user.email,
                      subject: "COMPLETED - Datastream Upload Job - #{coll_title}",
                      message: msg).deliver_now
    end

    def email_errors(user, coll_title, folder_path, errors )
      msg = <<~EOS
        ERRORS in Datastream Upload
        For collection: #{coll_title}
        From folder: #{folder_path}
        
        ERRORS:
        - #{errors.join("\n-")}
      EOS
      JobMailer.basic(to: user.email,
                      subject: "ERRORS - Datastream Upload Job - #{coll_title}",
                      message: msg).deliver_now
    end

    def collection_title(collection_id)
      Collection.find(collection_id).title.first
    end

    def batch_url(batch)
      Rails.application.routes.url_helpers.batch_url(batch, host: DulHydra.host_name, protocol: 'https')
    end

  end
end
