class MonitorNestedFolderIngest

  class << self
    def call(*args)
      event = ActiveSupport::Notifications::Event.new(*args)
      user = User.find_by_user_key(event.payload[:user_key])
      folder_path = File.join(event.payload[:basepath], event.payload[:subpath])
      collection_id = event.payload[:collection_id]
      file_count = event.payload[:file_count]
      model_stats = event.payload[:model_stats]
      errors = event.payload[:errors]
      batch = Ddr::Batch::Batch.find(event.payload[:batch_id]) if event.payload[:batch_id]
      coll_title = collection_title(collection_id, batch)
      if errors.present?
        email_errors(user, coll_title, folder_path, errors )
      else
        email_success(user, coll_title, folder_path, file_count, model_stats, batch)
      end
    end

    private

    def email_success(user, coll_title, folder_path, file_count, model_stats, batch)
      msg = <<~EOS
        Nested Folder Ingest has created batch ##{batch.id}
        For collection: #{coll_title}
        From folder: #{folder_path}
        Files found: #{file_count}
        Object model stats
          Collection: #{model_stats.fetch(:collections, 0)}
                Item: #{model_stats.fetch(:items, 0)}
           Component: #{model_stats.fetch(:components, 0)}

        To review and process the batch, go to #{batch_url(batch)}
      EOS
      JobMailer.basic(to: user.email,
                      subject: "BATCH CREATED - Nested Folder Ingest Job - #{coll_title}",
                      message: msg).deliver_now
    end

    def email_errors(user, coll_title, folder_path, errors )
      msg = <<~EOS
        ERRORS in Nested Folder Ingest
        For collection: #{coll_title}
        From folder: #{folder_path}
        
        ERRORS:
        - #{errors.join("\n-")}
      EOS
      JobMailer.basic(to: user.email,
                      subject: "ERRORS - Nested Folder Ingest Job - #{coll_title}",
                      message: msg).deliver_now
    end

    def collection_title(collection_id, batch)
      if collection_id.present?
        Collection.find(collection_id).title.first
      else
        if batch
          batch_object = batch.batch_objects.where(model: 'Collection').first
          titles = batch_object.batch_object_attributes.where(name: 'title')
          titles.empty? ? nil : titles.first.value
        end
      end
    end

    def batch_url(batch)
      Rails.application.routes.url_helpers.batch_url(batch, host: DulHydra.host_name, protocol: 'https')
    end

  end
end
